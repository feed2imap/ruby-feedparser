require 'feedparser'

module FeedParser
  class Feed
    def to_html
      s = ''
      s += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
      s += '<html>'
      s += '<body>'
      s += "<p>Type: #{@type}<br>"
      s += "Encoding: #{@encoding}<br>"
      s += "Title: #{@title}<br>"
      s += "Link: #{@link}<br>"
      s += "Description: #{@description}<br>"
      s += "Creator: #{@creator}</p>"
      s += "\n"
      @items.each do |i|
        s += '*' * 40 + "\n"
        s += i.to_html
      end
      s
    end
  end

  class FeedItem
    def to_html
      s = "<p>Feed: "
      s += "<a href=\"#{@feed.link}\">" if @feed.link
      s += @feed.title if @feed.title
      s += "</a>" if @feed.link
      s += "<br/>\nItem: "
      s += "<a href=\"#{@link}\">" if @link
      s += @title if @title
      s += "</a>" if @link
      s += "\n"
      s += "<br/>Date: #{@date.to_s}" if @date # TODO improve date rendering ?
      s += "<br/>Author: #{@creator}" if @creator
      s += "<br/>Subject: #{@subject}" if @subject
      s += "<br/>Category: #{@category}" if @category
      s += "</p>"
      s += "<p>#{@content}</p>" if @content
      s += '</body></html>'
      s
    end
  end
end
