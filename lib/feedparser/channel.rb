# This class allows to retrieve a feed and parse it into a Channel

require 'rexml/document'
require 'time'
require 'feedparser/textconverters'
require 'feedparser/rexml_patch'
require 'base64'

module FeedParser

  class UnknownFeedTypeException < RuntimeError
  end

  # an RSS/Atom channel
  class Feed
    attr_reader :type, :title, :link, :description, :creator, :encoding, :items

    # parse str to build a channel
    def initialize(str = nil)
      parse(str) if str
    end

    # Determines all the fields using a string containing an
    # XML document
    def parse(str)
      # Dirty hack: some feeds contain the & char. It must be changed to &amp;
      str.gsub!(/&(\s+)/, '&amp;\1')
      doc = REXML::Document.new(str)
      # get channel info
      @encoding = doc.encoding
      @title,@link,@description,@creator = nil
      @items = []
      if doc.root.elements['channel'] || doc.root.elements['rss:channel']
        @type = "rss"
        # We have a RSS feed!
        # Title
        if (e = doc.root.elements['channel/title'] ||
          doc.root.elements['rss:channel/rss:title']) && e.text
          @title = e.text.toUTF8(@encoding).rmWhiteSpace!
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
          @creator = e.text.toUTF8(@encoding).rmWhiteSpace!
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
          @title = e.text.toUTF8(@encoding).rmWhiteSpace!
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
          @description = e.elements.to_s.toUTF8(@encoding).rmWhiteSpace!
        end
        # Items
        doc.root.each_element('/feed/entry') do |e|
           @items << AtomItem::new(e, self)
        end
      else
        raise UnknownFeedTypeException::new
      end
    end

    def to_s
      s = "Title: #{@title}\nLink: #{@link}\n\n"
      @items.each { |i| s += i.to_s }
      s
    end
  end

# an Item from a channel
  class FeedItem
    attr_accessor :title, :link, :content, :date, :creator, :subject,
                  :category, :cacheditem
    attr_reader :feed
    def initialize(item = nil, feed = nil)
      @feed = feed
      @title, @link, @content, @date, @creator, @subject, @category = nil
      parse(item) if item
    end

    def parse(item)
      raise "parse() should be implemented by subclasses!"
    end

    def to_s
      "--------------------------------\n" +
        "Title: #{@title}\nLink: #{@link}\n" +
        "Date: #{@date.to_s}\nCreator: #{@creator}\n" +
        "Subject: #{@subject}\nCategory: #{@category}\nContent:\n#{content}\n"
    end
  end

  class RSSItem < FeedItem
    def parse(item)
      # Title. If no title, use the pubDate as fallback.
      if ((e = item.elements['title'] || item.elements['rss:title']) &&
          e.text)  ||
          ((e = item.elements['pubDate'] || item.elements['rss:pubDate']) &&
           e.text)
        @title = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Link
      if ((e = item.elements['link'] || item.elements['rss:link']) && e.text)||
          (e = item.elements['guid'] || item.elements['rss:guid'] and
          not (e.attribute('isPermaLink') and
          e.attribute('isPermaLink').value == 'false'))
        @link = e.text.rmWhiteSpace!
      end
      # Content
      if (e = item.elements['content:encoded']) ||
        (e = item.elements['description'] || item.elements['rss:description'])
        if e.children.length > 1
          s = ''
          e.children.each { |c| s += c.to_s }
          @content = s.toUTF8(@channel.encoding).rmWhiteSpace!.text2html
        elsif e.children.length == 1
          if e.cdatas[0]
            @content = e.cdatas[0].to_s.toUTF8(@channel.encoding).rmWhiteSpace!
          elsif e.text
            @content = e.text.toUTF8(@channel.encoding).text2html
          end
        end
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
      @creator = @channel.creator
      if (e = item.elements['dc:creator'] || item.elements['author'] ||
          item.elements['rss:author']) && e.text
        @creator = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Subject
      if (e = item.elements['dc:subject']) && e.text
        @subject = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Category
      if (e = item.elements['dc:category'] || item.elements['category'] ||
          item.elements['rss:category']) && e.text
        @category = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
    end
  end

  class AtomItem < FeedItem
    def parse(item)
      # Title
      if (e = item.elements['title']) && e.text
        @title = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Link
      item.each_element('link') do |e|
        if e.attribute('type').value == 'text/html' or
          e.attribute('type').value == 'application/xhtml' or
          e.attribute('type').value == 'application/xhtml+xml'
          if (h = e.attribute('href')) && h.value
            @link = h.value
          end
        end
      end
      # Content
      if e = item.elements['content'] || item.elements['summary']
        if (e.attribute('mode') and e.attribute('mode').value == 'escaped') &&
          e.text
          @content = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
        else
          # go one step deeper in the recursion if possible
          e = e.elements['div'] || e
          @content = e.to_s.toUTF8(@channel.encoding).rmWhiteSpace!
        end
      end
      # Date
      if (e = item.elements['issued'] || e = item.elements['created']) && e.text
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
      @creator = @channel.creator
      if (e = item.elements['author/name']) && e.text
        @creator = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
    end
  end
end
