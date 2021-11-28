require 'feedparser'
require 'feedparser/filesizes'

module FeedParser
  STYLESHEET = <<~EOF
  <style type="text/css">
  body {
    margin: 2em auto;
    max-width: 960px;
  }
  </style>
  EOF
  class Feed
    def to_html(localtime = true)
      s = ''
      s += "<!doctype html>\n"
      s += "<html lang=en>\n"
      s += "<head>\n"
      s += "<meta charset=\"utf-8\"/>\n"
      s += "<title>#{@title.escape_html}</title>\n"
      s += FeedParser::STYLESHEET
      s += "</head>\n"
      s += "<body>\n"

      s += <<-EOF
<table class="feed-header">
      EOF
      r = ""
      r += "<a href=\"#{@link}\">\n" if @link
      if @title
        r += @title.escape_html
      elsif @link
        r += @link.escape_html
      else
        r += "Unnamed feed"
      end
      r += "</a>\n" if @link
      headline = "<tr><th>%s</th>\n<td>%s</td></tr>"
      s += (headline % ["Feed title:", r])
      s += (headline % ["Type:", @type])
      s += (headline % ["Encoding:", @encoding])
      s += (headline % ["Creator:", @creator.escape_html]) if @creator
      s += "</table>\n"

      if @description and @description !~ /\A\s*</m
        s += "<br/>\n"
      end
      s += "#{@description}" if @description

      @items.each do |i|
        s += "\n<hr/><!-- *********************************** -->\n"
        s += i.to_html(localtime)
      end
      s += "\n</body></html>\n"
      s
    end
  end

  class FeedItem
    def to_html_with_headers(localtime = true)
      s = "<!doctype html>\n"
      s += '<html lang="en">'
      s += '<head>'
      s += '<meta charset="utf-8"/>'
      s += "<title>#{@title.escape_html}</title>\n"
      s += FeedParser::STYLESHEET
      s += '</head>'
      s += '<body>'
      s += to_html(localtime)
      s += "</body>"
      s += "</html>"
      s
    end

    def to_html(localtime = true)
      s = <<-EOF
<table class="header">
      EOF
      r = ""
      r += "<a href=\"#{@feed.link}\">\n" if @feed.link
      if @feed.title
        r += @feed.title.escape_html
      elsif @feed.link
        r += @feed.link.escape_html
      else
        r += "Unnamed feed"
      end
      r += "</a>\n" if @feed.link
      headline = "<tr><th>%s</th>\n<td>%s</td></tr>"
      s += (headline % ["Feed:", r])

      r = ""
      r += "<a href=\"#{link}\">" if link
      if @title
        r += @title.escape_html
      elsif link
        r += link.escape_html
      end
      r += "</a>\n" if link
      s += (headline % ["Item:", r])
      s += "</table>\n"
      s += "\n"
      if @content and @content !~ /\A\s*</m
        s += "<br/>\n"
      end
      s += "#{@content}" if @content
      if @enclosures and @enclosures.length > 0
        s += <<-EOF
<table class="attachments">
        EOF
        s += '<tr><th>Files:</th></tr>'
        s += "\n"
        @enclosures.each do |e|
          s += "<tr><td><a href=\"#{e[0]}\">#{e[0].split('/')[-1]}</a> (#{e[1].to_i.to_human_readable}, #{e[2]})</td></tr>\n"
        end
        s += "</table>\n"
      end
      s += "\n<hr/>\n"
      s += '<table class="metadata">' + "\n"
      l = '<tr><th>%s</th><td>%s</td></tr>' + "\n"
      if @date
        if localtime
          s += l % [ 'Date:', @date.to_s ]
        else
          s += l % [ 'Date:', @date.getutc.to_s ]
        end
      end
      s += l % [ 'Author:', creator.escape_html ] if creator
      s += l % [ 'Subject:', @subject.escape_html ] if @subject
      s += l % [ 'Filed under:', @categories.join(', ').escape_html ] unless @categories.empty?
      s += "</table>\n"
      s
    end
  end
end
