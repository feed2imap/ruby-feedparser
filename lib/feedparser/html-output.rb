require 'feedparser'
require 'feedparser/filesizes'

module FeedParser
  class Feed
    def to_html
      s = ''
      s += '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
      s += "\n"
      s += "<html>\n"
      s += "<head>\n"
      s += "<title>#{@title.escape_html}</title>\n"
      s += "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\">\n"
      s += "</head>\n"
      s += "<body>\n"

      s += <<-EOF
<table border="1" width="100%" cellpadding="0" cellspacing="0" borderspacing="0"><tr><td>
<table width="100%" bgcolor="#EDEDED" cellpadding="4" cellspacing="2">
      EOF
      r = ""
      r += "<a href=\"#{@link}\">\n" if @link
      if @title
        r += "<b>#{@title.escape_html}</b>\n"
      elsif @link
        r += "<b>#{@link.escape_html}</b>\n"
      else
        r += "<b>Unnamed feed</b>\n"
      end
      r += "</a>\n" if @link
      headline = "<tr><td align=\"right\"><b>%s</b></td>\n<td width=\"100%%\">%s</td></tr>"
      s += (headline % ["Feed title:", r])
      s += (headline % ["Type:", @type])
      s += (headline % ["Encoding:", @encoding])
      s += (headline % ["Creator:", @creator.escape_html]) if @creator
      s += "</table></td></tr></table>\n"

      if @description and @description !~ /\A\s*</m
        s += "<br/>\n"
      end
      s += "#{@description}" if @description

      @items.each do |i|
        s += "\n<hr/><!-- *********************************** -->\n"
        s += i.to_html
      end
      s += "\n</body></html>\n"
      s
    end
  end

  class FeedItem
    def to_html_with_headers
      s = <<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<body>
  EOF
      s += to_html
      s += "\n</body>\n</html>"
      s
    end

    def to_html
      s = <<-EOF
<table border="1" width="100%" cellpadding="0" cellspacing="0" borderspacing="0"><tr><td>
<table width="100%" bgcolor="#EDEDED" cellpadding="4" cellspacing="2">
      EOF
      r = ""
      r += "<a href=\"#{@feed.link}\">\n" if @feed.link
      if @feed.title
        r += "<b>#{@feed.title.escape_html}</b>\n"
      elsif @feed.link
        r += "<b>#{@feed.link.escape_html}</b>\n"
      else
        r += "<b>Unnamed feed</b>\n"
      end
      r += "</a>\n" if @feed.link
      headline = "<tr><td align=\"right\"><b>%s</b></td>\n<td width=\"100%%\">%s</td></tr>"
      s += (headline % ["Feed:", r])

      r = ""
      r += "<a href=\"#{@link}\">" if @link
      if @title
        r += "<b>#{@title.escape_html}</b>\n"
      elsif @link
        r += "<b>#{@link.escape_html}</b>\n"
      end
      r += "</a>\n" if @link
      s += (headline % ["Item:", r])
      s += "</table></td></tr></table>\n"
      s += "\n"
      if @content and @content !~ /\A\s*</m
        s += "<br/>\n"
      end
      s += "#{@content}" if @content
      if @enclosures and @enclosures.length > 0
        s += <<-EOF
<table border="1" width="100%" cellpadding="0" cellspacing="0" borderspacing="0"><tr><td>
<table width="100%" bgcolor="#EDEDED" cellpadding="2" cellspacing="2">
        EOF
        s += '<tr><td width="100%"><b>Files:</b></td></tr>'
        s += "\n"
        @enclosures.each do |e|
          s += "<tr><td>&nbsp;&nbsp;&nbsp;<a href=\"#{e[0]}\">#{e[0].split('/')[-1]}</a> (#{e[1].to_i.to_human_readable}, #{e[2]})</td></tr>\n"
        end
        s += "</table></td></tr></table>\n"
      end
      s += "<hr width=\"100%\"/>"
      s += '<table width="100%" cellpadding="0" cellspacing="0">'
      l = '<tr><td align="right"><font color="#ababab">%s</font>&nbsp;&nbsp;</td><td><font color="#ababab">%s</font></td></tr>' + "\n"
      s += l % [ 'Date:', @date.to_s ] if @date # TODO improve date rendering ?
      s += l % [ 'Author:', @creator.escape_html ] if @creator
      s += l % [ 'Subject:', @subject.escape_html ] if @subject
      s += l % [ 'Category:', @category.escape_html ] if @category
      s += "</table>\n"
      s
    end
  end
end
