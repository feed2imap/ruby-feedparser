require 'cgi'
require 'rexml/document'
require 'time'
require 'feedparser/textconverters'
require 'feedparser/rexml_patch'
require 'feedparser/text-output'
require 'feedparser/version'
require 'base64'
require 'magic'
require 'uri'

module FeedParser

  class UnknownFeedTypeException < RuntimeError
  end

  def self.recode(str)
    encoding = nil
    begin
      encoding = Magic.guess_string_mime_encoding(str)
    rescue => e
      raise unless e.class.to_s =~ /\AMagic::(?:Exception|Error)\z/
      # this happens when magic does not find any content at all, e.g. with
      # strings that contain only whitespace. In these case it *should* be safe
      # to assume UTF-8
      encoding = Encoding::UTF_8
    end
    if encoding == 'unknown-8bit'
      # find first substring with a valid encoding that is not us-ascii
      length = 1 # has to start at 1, magic requires at least 2 bytes
      while length < str.length && ['us-ascii', 'unknown-8bit'].include?(encoding)
        encoding = Magic.guess_string_mime_encoding(str[0..length])
        length = length + 1
      end
      # need to remove iso-8859-1 control characters
      if encoding == 'iso-8859-1'
        str = str.bytes.select { |c| c < 128 || c > 159 }.map(&:chr).join
      end
    end
    str.force_encoding(encoding)
    str = str.chars.select { |c| c.valid_encoding? }.join
    str.encode('UTF-8')
  end

  # an RSS/Atom feed
  class Feed
    attr_reader :type, :title, :link, :description, :creator, :encoding, :items

    # REXML::Element for this feed.
    attr_reader :xml

    # parse str to build a Feed
    def initialize(str = nil, uri = nil)
      parse(str) if str
      parse_origin(uri) if uri
    end

    # Determines all the fields using a string containing an
    # XML document
    def parse(str)
      str = FeedParser.recode(str)

      # Dirty hack: some feeds contain the & char. It must be changed to &amp;
      str.gsub!(/&(\s+)/, '&amp;\1')
      doc = REXML::Document.new(str)
      @xml = doc.root
      # get feed info
      @encoding = doc.encoding
      @title,@link,@description,@creator = nil
      @title = ""
      @items = []
      if doc.root.elements['channel'] || doc.root.elements['rss:channel']
        @type = "rss"
        # We have a RSS feed!
        # Title
        if (e = doc.root.elements['channel/title'] ||
          doc.root.elements['rss:channel/rss:title']) && e.text
          @title = e.text.unescape_html.toUTF8(@encoding).rmWhiteSpace!
        end
        # Link
        if (e = doc.root.elements['channel/link'] ||
            doc.root.elements['rss:channel/rss:link']) && e.text
          @link = e.text.rmWhiteSpace!
        end
        # Description
        if (e = doc.root.elements['channel/description'] || 
            doc.root.elements['rss:channel/rss:description']) && e.text
          @description = e.text.toUTF8(@encoding).rmWhiteSpace!
        end
        # Creator
        if ((e = doc.root.elements['channel/dc:creator']) && e.text) ||
            ((e = doc.root.elements['channel/author'] ||
            doc.root.elements['rss:channel/rss:author']) && e.text)
          @creator = e.text.unescape_html.toUTF8(@encoding).rmWhiteSpace!
        end
        # Items
        if doc.root.elements['channel/item']
          query = 'channel/item'
        elsif doc.root.elements['item']
          query = 'item'
        elsif doc.root.elements['rss:channel/rss:item']
          query = 'rss:channel/rss:item'
        else
          query = 'rss:item'
        end
        doc.root.each_element(query) { |e| @items << RSSItem::new(e, self) }

      elsif doc.root.elements['/feed']
        # We have an ATOM feed!
        @type = "atom"
        # Title
        if (e = doc.root.elements['/feed/title']) && e.text
          @title = e.text.unescape_html.toUTF8(@encoding).rmWhiteSpace!
        end
        # Link
        doc.root.each_element('/feed/link') do |e|
          if e.attribute('type') and (
              e.attribute('type').value == 'text/html' or
              e.attribute('type').value == 'application/xhtml' or
              e.attribute('type').value == 'application/xhtml+xml')
            if (h = e.attribute('href')) && h
              @link = h.value.rmWhiteSpace!
            end
          end
        end
        # Description
        if e = doc.root.elements['/feed/info']
          e = e.elements['div'] || e
          @description = e.to_s.toUTF8(@encoding).rmWhiteSpace!
        end
        # Items
        doc.root.each_element('/feed/entry') do |e|
           @items << AtomItem::new(e, self)
        end
      else
        raise UnknownFeedTypeException::new
      end
    end

    def to_s(localtime = true)
      s  = ''
      s += "Type: #{@type}\n"
      s += "Encoding: #{@encoding}\n"
      s += "Title: #{@title}\n"
      s += "Link: #{link}\n"
      s += "Description: #{@description}\n"
      s += "Creator: #{@creator}\n"
      s += "\n"
      @items.each { |i| s += i.to_s(localtime) }
      s
    end

    def parse_origin(uri)
      uri = URI.parse(uri)
      if uri.hostname && uri.scheme
        @origin = "#{uri.scheme}://#{uri.hostname}"
      end
    end

    attr_reader :origin
  end

  # an Item from a feed
  class FeedItem
    attr_accessor :title, :content, :date, :creators, :subject,
                  :cacheditem, :links

    # The item's categories/tags. An array of strings.
    attr_accessor :categories

    # The item's enclosures childs. An array of (url, length, type) triplets.
    attr_accessor :enclosures

    attr_reader :feed

    # REXML::Element for this item
    attr_reader :xml

    def initialize(item = nil, feed = nil)
      @xml = item
      @feed = feed
      @title, @link, @content, @date, @subject = nil
      @links = []
      @creators = []
      @categories = []
      @enclosures = []

      @title = ""
      parse(item) if item
    end

    def parse(item)
      raise "parse() should be implemented by subclasses!"
    end

    def creator
      case @creators.length
      when 0
        return nil
      when 1
        return creators[0]
      else
        sorted_creators = creators.sort
        return sorted_creators[0...-1].join(", ") + " and " + sorted_creators[-1]
      end
    end

    def to_s(localtime = true)
      s = "--------------------------------\n" +
        "Title: #{@title}\nLink: #{link}\n"
      if localtime or @date.nil?
        s += "Date: #{@date.to_s}\n"
      else
        s += "Date: #{@date.getutc.to_s}\n"
      end
      s += "Creator: #{creator}\n" +
        "Subject: #{@subject}\n"
      if defined?(@categories) and @categories.length > 0
        s += "Filed under: " + @categories.join(', ') + "\n"
      end
      s += "Content:\n#{content}\n"
      if defined?(@enclosures) and @enclosures.length > 0
        s2 = "Enclosures:\n"
        @enclosures.each do |e|
          s2 += e.join(' ') + "\n"
        end
        s += s2
      end
      return s
    end

    attr_writer :link

    def link
      if @link
        begin
          uri = URI.parse(@link)
        rescue URI::InvalidURIError
          return @link
        end
        if uri.hostname && uri.scheme
          @link
        elsif feed && feed.origin
          [feed.origin, @link].compact.join
        else
          @link
        end
      end
    end

  end

  class RSSItem < FeedItem


    def parse(item)
      # Title. If no title, use the pubDate as fallback.
      if ((e = item.elements['title'] || item.elements['rss:title']) &&
          e.text)  ||
          ((e = item.elements['pubDate'] || item.elements['rss:pubDate']) &&
           e.text)
        @title = e.text.unescape_html.toUTF8(@feed.encoding).html2text.rmWhiteSpace!
      end
      # Link
      if ((e = item.elements['link'] || item.elements['rss:link']) && e.text)||
          (e = item.elements['guid'] || item.elements['rss:guid'] and
          not (e.attribute('isPermaLink') and
          e.attribute('isPermaLink').value == 'false'))
        self.link = e.text.rmWhiteSpace!
      end
      # Content
      if (e = item.elements['content:encoded']) ||
        (e = item.elements['description'] || item.elements['rss:description'])
        @content = FeedParser::getcontent(e, @feed)
      end
      # Date
      if e = item.elements['dc:date'] || item.elements['pubDate'] || 
          item.elements['rss:pubDate']
        begin
          @date = Time::xmlschema(e.text)
        rescue
          begin
            @date = Time::rfc2822(e.text)
          rescue
            begin
              @date = Time::parse(e.text)
            rescue
              @date = nil
            end
          end
        end
      end
      # Creator
      if (e = item.elements['dc:creator'] || item.elements['author'] ||
          item.elements['rss:author']) && e.text
        @creators << e.text.unescape_html.toUTF8(@feed.encoding).rmWhiteSpace!
      end
      @creators << @feed.creator if @creators.empty? and @feed.creator

      # Subject
      if (e = item.elements['dc:subject']) && e.text
        @subject = e.text.unescape_html.toUTF8(@feed.encoding).rmWhiteSpace!
      end
      # Categories
      cat_elts = []
      item.each_element('dc:category')  { |e| cat_elts << e if e.text }
      item.each_element('category')     { |e| cat_elts << e if e.text }
      item.each_element('rss:category') { |e| cat_elts << e if e.text }

      cat_elts.each do |e|
        @categories << e.text.unescape_html.toUTF8(@feed.encoding).rmWhiteSpace!
      end
      # Enclosures
      item.each_element('enclosure') do |e|
        url = e.attribute('url').value if e.attribute('url')
        length = e.attribute('length').value if e.attribute('length')
        type = e.attribute('type').value if e.attribute('type')
        @enclosures << [ url, length, type ] if url
      end
    end
  end

  class AtomItem < FeedItem
    def parse(item)
      # Title
      if (e = item.elements['title']) && e.text
        @title = e.text.unescape_html.toUTF8(@feed.encoding).html2text.rmWhiteSpace!
      end
      # Link
      item.each_element('link') do |e|

        if (h = e.attribute('href')) && h.value
          self.link = h.value

          if e.attribute('type')
            @links << {:href => h.value, :type => e.attribute('type').value}
          else
            @links << {:href => h.value, :type => ''}
          end

        end
      end
      # Content
      if e = item.elements['content'] || item.elements['summary']
        if (e.attribute('mode') and e.attribute('mode').value == 'escaped') &&
          e.text
          @content = e.text.toUTF8(@feed.encoding).rmWhiteSpace!
        else
          @content = FeedParser::getcontent(e, @feed)
        end
      end
      # Date
      if (e = item.elements['issued'] || e = item.elements['created'] || e = item.elements['updated'] || e = item.elements['published']) && e.text
        begin
          @date = Time::xmlschema(e.text)
        rescue
          begin
            @date = Time::rfc2822(e.text)
          rescue
            begin
              @date = Time::parse(e.text)
            rescue
              @date = nil
            end
          end
        end
      end
      # Creator
      item.each_element('author/name') do |e|
        if e.text
          @creators << e.text.unescape_html.toUTF8(@feed.encoding).rmWhiteSpace!
        end
      end

      @creators << @feed.creator if @creators.empty? and @feed.creator

      # Categories
      item.each_element('category') do |e|
        if (h = e.attribute('term')) && h.value
          # Use human-readable label if it is provided
          if (l = e.attribute('label')) && l.value
            cat = l.value
          else
            cat = h.value
          end

          @categories << cat.unescape_html.toUTF8(@feed.encoding).rmWhiteSpace!
        end
      end
    end
  end

  def FeedParser::getcontent(e, feed = nil)
    encoding = feed ? feed.encoding : 'utf-8'
    children = e.children.reject do |i|
      i.class == REXML::Text and i.to_s.chomp == ''
    end
    if children.length > 1
      s = ''
      children.each do |c|
        s += c.to_s if c.class != REXML::Comment
      end
      return s.toUTF8(encoding).rmWhiteSpace!.text2html(feed)
    elsif children.length == 1
      c = children[0]
      if c.class == REXML::Text
        return e.text.toUTF8(encoding).rmWhiteSpace!.text2html(feed)
      elsif c.class == REXML::CData
        return c.to_s.toUTF8(encoding).rmWhiteSpace!.text2html(feed)
      elsif c.class == REXML::Element
        # only one element. recurse.
        return getcontent(c, feed)
      elsif c.text
        return c.text.toUTF8(encoding).text2html(feed)
      end
    end
  end
end
