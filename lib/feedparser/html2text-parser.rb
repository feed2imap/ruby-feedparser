require 'feedparser/sgml-parser'

# this class provides a simple SGML parser that removes HTML tags
class HTML2TextParser < SGMLParser

  attr_reader :savedata

  def initialize(verbose = false)
    @savedata = ''
    @pre = false
    @href = nil
    @links = []
    super(verbose)
  end

  def handle_data(data)
    # let's remove all CR
    data.gsub!(/\n/, '') if not @pre
 
    @savedata << data
  end

  def unknown_starttag(tag, attrs)
    case tag
    when 'p'
      @savedata << "\n\n"
    when 'br'
      @savedata << "\n"
    when 'b'
      @savedata << '*'
    when 'u'
      @savedata << '_'
    when 'i'
      @savedata << '/'
    when 'pre'
      @savedata << "\n\n"
      @pre = true
    when 'a'
      # find href in args
      @href = nil
      attrs.each do |a|
        if a[0] == 'href'
          @href = a[1]
        end
      end
      if @href
        @links << @href.gsub(/^("|'|)(.*)("|')$/,'\2')
      end
    end
  end

  def close
    super
    if @links.length > 0
      @savedata << "\n\n"
      @links.each_index do |i|
        @savedata << "[#{i+1}] #{@links[i]}\n"
      end
    end
  end

  def unknown_endtag(tag)
    case tag
    when 'b'
      @savedata << '*'
    when 'u'
      @savedata << '_'
    when 'i'
      @savedata << '/'
    when 'pre'
      @savedata << "\n\n"
      @pre = false
    when 'a'
      if @href
        @savedata << "[#{@links.length}]"
        @href = nil
      end
    end
  end
end
