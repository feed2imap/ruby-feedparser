require 'feedparser'
require 'feedparser/html2text-parser'
require 'feedparser/filesizes'

class String
  # Convert an HTML text to plain text
  def html2text
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
    text
  end
end

module FeedParser
  class Feed
    def to_text(localtime = true)
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
        s += i.to_text(localtime)
      end
      s
    end
  end

  class FeedItem
    def to_text(localtime = true)
      s = ""
      s += "Feed: "
      s += @feed.title + ' ' if @feed.title
      s += "<#{@feed.link}>" if @feed.link
      s += "\n"
      s += "Item: "
      s += @title + ' ' if @title
      s += "<#{@link}>" if @link
      s += "\n"
      if @date
        if localtime
          s += "\nDate: #{@date.to_s}"
        else
          s += "\nDate: #{@date.getutc.to_s}"
        end
      end
      s += "\nAuthor: #{@creator}" if @creator
      s += "\nSubject: #{@subject}" if @subject
      s += "\nCategory: #{@category}" if @category
      s += "\n\n"
      s += "#{@content.html2text}\n" if @content
      if @enclosures and @enclosures.length > 0
        s += "Files:\n"
        @enclosures.each do |e|
          s += " #{e[0]} (#{e[1].to_i.to_human_readable}, #{e[2]})\n"
        end
      end
      s 
    end
  end
end
