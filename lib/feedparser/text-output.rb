require 'feedparser/html2text-parser'
require 'feedparser/filesizes'

class String
  # Convert an HTML text to plain text
  def html2text(wrapto = false)
    text = self.clone
    # parse HTML
    p = FeedParser::HTML2TextParser::new(true)
    p.feed(text)
    p.close
    text = p.savedata
    # remove leading and trailing whilespace
    text.gsub!(/\A\s*/m, '')
    text.gsub!(/\s*\Z/m, '')
    # remove whitespace around \n
    text.gsub!(/ *\n/m, "\n")
    text.gsub!(/\n */m, "\n")
    # and duplicates \n
    text.gsub!(/\n\n+/m, "\n\n")
    # and remove duplicated whitespace
    text.gsub!(/[ \t]+/, ' ')

    # finally, wrap the text if requested
    return wrap_text(text, wrapto) if wrapto
    text
  end

  def wrap_text(text, wrapto = 72)
    text.gsub(/(.{1,#{wrapto}})( +|$)\n?/, "\\1\\2\n")
  end
end

module FeedParser
  class Feed
    def to_text(localtime = true, wrapto = false)
      s = ''
      s += "Type: #{@type}\n"
      s += "Encoding: #{@encoding}\n"
      s += "Title: #{@title}\n"
      s += "Link: #{@link}\n"
      if @description
        s += "Description: #{@description.html2text}\n"
      else
        s += "Description:\n"
      end
      s += "Creator: #{@creator}\n"
      s += "\n"
      @items.each do |i|
        s += '*' * 40 + "\n"
        s += i.to_text(localtime, wrapto)
      end
      s
    end
  end

  class FeedItem
    def to_text(localtime = true, wrapto = false, header = true)
      s = ""
      if header
        s += "Item: "
        s += @title if @title
        s += "\n<#{@link}>" if @link
        if @date
          if localtime
            s += "\nDate: #{@date.to_s}"
          else
            s += "\nDate: #{@date.getutc.to_s}"
          end
        end
        s += "\n"
      else
        s += "<#{@link}>\n\n" if @link
      end
      s += "#{@content.html2text(wrapto).chomp}\n" if @content
      if @enclosures and @enclosures.length > 0
        s += "\nFiles:"
        @enclosures.each do |e|
          s += "\n #{e[0]} (#{e[1].to_i.to_human_readable}, #{e[2]})"
        end
      end
      if not header
        s += "-- "
      end
      s += "\nFeed: "
      s += @feed.title if @feed.title
      s += "\n<#{@feed.link}>" if @feed.link
      if not header
        s += "\nItem: "
        s += @title if @title
        s += "\n<#{@link}>" if @link
        if @date
          if localtime
            s += "\nDate: #{@date.to_s}"
          else
            s += "\nDate: #{@date.getutc.to_s}"
          end
        end
      end
      s += "\nAuthor: #{creator}" if creator
      s += "\nSubject: #{@subject}" if @subject
      s += "\nFiled under: #{@categories.join(', ')}" unless @categories.empty?
      s += "\n" # final newline, for compat with history
      s 
    end
  end
end
