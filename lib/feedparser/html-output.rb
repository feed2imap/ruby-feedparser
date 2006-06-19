require 'feedparser'

module FeedParser
  class Feed
    def to_html
      s = ''
      s += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
      s += "\n"
      s += "<html>\n"
      s += "<body>\n"
      s += "<p>Type: #{@type}<br>\n"
      s += "Encoding: #{@encoding}<br>\n"
      s += "Title: #{@title.escape_html}<br>\n"
      s += "Link: #{@link}<br>\n" 
      s += "Description: #{@description}<br>\n"
      s += "Creator: #{@creator ? @creator.escape_html : ''}</p>\n"
      s += "\n"
      @items.each do |i|
        s += "\n<hr/><!-- *********************************** -->\n"
        s += i.to_html
      end
      s
    end
  end

  class FeedItem
    def to_html
      s = "<p>Feed: "
      s += "<a href=\"#{@feed.link}\">\n" if @feed.link
      s += "#{@feed.title.escape_html}\n" if @feed.title
      s += "</a>\n" if @feed.link
      s += "<br/>\nItem: "
      s += "<a href=\"#{@link}\">\n" if @link
      s += "#{@title.escape_html}\n" if @title
      s += "</a>\n" if @link
      s += "\n"
      s += "<br/>Date: #{@date.to_s}\n" if @date # TODO improve date rendering ?
      s += "<br/>Author: #{@creator.escape_html}\n" if @creator
      s += "<br/>Subject: #{@subject.escape_html}\n" if @subject
      s += "<br/>Category: #{@category.escape_html}\n" if @category
      s += "</p>\n"
      s += "#{@content}" if @content
      s += '</body></html>'
      s
    end
  end
end
