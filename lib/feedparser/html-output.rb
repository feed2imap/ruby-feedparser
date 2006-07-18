require 'feedparser'
require 'feedparser/filesizes'

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
      s += "\n</body></html>\n"
      s
    end
  end

  class FeedItem
    def to_html
      s = <<-EOF
<style type=\"text/css\">
<!--
table.itemhead {
  margin-bottom:10px;
  width:100%;
  background-color:#DDD;
  border: 1px solid black;
  clear:both;
}
-->
</style>
      EOF
      
      s += "<table cellspacing=\"0\" class=\"itemhead\">\n"
      r = "<span class=\"feedlink\">"
      r += "<a href=\"#{@feed.link}\">\n" if @feed.link
      if @feed.title
        r += "#{@feed.title.escape_html}\n"
      elsif @feed.link
        r += "#{@feed.link.escape_html}\n"
      end
      r += "</a>\n" if @feed.link
      r += "</span>\n"
      headline = "<tr><td class=\"headleft\"><b>%s</b></td>\n<td class=\"headright\" width=\"100%%\">%s</td></tr>"
      s += (headline % ["Feed:", r])

      r = "<span class=\"itemtitle\">\n"
      r += "<a href=\"#{@link}\">" if @link
      if @title
        r += "#{@title.escape_html}\n"
      elsif @link
        r += "#{@link.escape_html}\n"
      end
      r += "</a>\n" if @link
      r += "</span>\n"
      s += (headline % ["Item:", r])
      s += "</table>\n"
      s += "\n"
      s += "<br/>Date: #{@date.to_s}\n" if @date # TODO improve date rendering ?
      s += "<br/>Author: #{@creator.escape_html}\n" if @creator
      s += "<br/>Subject: #{@subject.escape_html}\n" if @subject
      s += "<br/>Category: #{@category.escape_html}\n" if @category
      s += "</p>\n"
      s += "#{@content}" if @content
      if @enclosures and @enclosures.length > 0
        s += "\n<p>Files:</p>\n<ul>\n"
        @enclosures.each do |e|
          s += "<li><a href=\"#{e[0]}\">#{e[0].split('/')[-1]}</a> (#{e[1].to_i.to_human_readable}, #{e[2]})</li>\n"
        end
        s += "</ul>\n"
      end
      s
    end
  end
end
