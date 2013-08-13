require 'feedparser/sgml-parser'

module FeedParser
# this class provides a simple SGML parser that removes HTML tags
  class HTML2TextParser < SGMLParser

    attr_reader :savedata

    def initialize(verbose = false)
      @savedata = ''
      @pre = false
      @href = nil
      @links = []
      @curlink = []
      @imgs = []
      @img_index = 'A'
      super(verbose)
    end

    def next_img_index
      idx = @img_index
      @img_index = @img_index.next
      idx
    end

    def handle_data(data)
      # let's remove all CR
      if not @pre
        data.gsub!(/\n/, ' ') 
        data.gsub!(/( )+/, ' ')
      end
      @savedata << data
    end

    def unknown_starttag(tag, attrs)
      case tag
      when 'p', 'h4'
        @savedata << "\n\n"
      when 'h1'
        @savedata << "\n\n      "
      when 'h2'
        @savedata << "\n\n    "
      when 'h3'
        @savedata << "\n\n  "
      when 'br'
        @savedata << "\n"
      when 'ul'
        @savedata << "\n"
      when 'li'
        @savedata << "\n - "
      when 'b'
        @savedata << '*'
      when 'strong'
        @savedata << '*'
      when 'em'
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
          @href.gsub!(/^("|'|)(.*)("|')$/,'\2')
          @curlink = @links.find_index(@href)
          if @curlink.nil?
            @links << @href
            @curlink = @links.length
          else
            @curlink += 1
          end
        end
      when 'img'
        # find src in args
        src = nil
        attrs.each do |a|
          if a[0] == 'src'
            src = a[1]
          end
        end
        if src
          src.gsub!(/^("|'|)(.*)("|')$/,'\2')
          i = @imgs.index { |e| e[1] == src }
          if i.nil?
            idx = next_img_index
            @imgs << [ idx, src ]
          else
            idx = @imgs[i][0]
          end
          @savedata << "[#{idx}]"
        end
      else
#        puts "unknown tag: #{tag}"
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
      if @imgs.length > 0
        @savedata << "\n\n"
        @imgs.each do |i|
          @savedata << "[#{i[0]}] #{i[1]}\n"
        end
      end
    end

    def unknown_endtag(tag)
      case tag
      when 'ul'
        @savedata << "\n"
      when 'b'
        @savedata << '*'
      when 'strong'
        @savedata << '*'
      when 'em'
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
          @savedata << "[#{@curlink}]"
          @href = nil
        end
      end
    end

    def unknown_charref(ref)
      handle_data([ref.to_i].pack('U*'))
    end

    def HTML2TextParser.entities
      return HTML_ENTITIES
    end

    HTML_ENTITIES = {
      "quot" => 34,
      "amp" => 38,
      "lt" => 60,
      "gt" => 62,
      "apos" => 39,

      "nbsp" => 160,
      "iexcl" => 161,
      "cent" => 162,
      "pound" => 163,
      "curren" => 164,
      "yen" => 165,
      "brvbar" => 166,
      "sect" => 167,
      "uml" => 168,
      "copy" => 169,
      "ordf" => 170,
      "laquo" => 171,
      "not" => 172,
      "shy" => 173,
      "reg" => 174,
      "macr" => 175,
      "deg" => 176,
      "plusmn" => 177,
      "sup2" => 178,
      "sup3" => 179,
      "acute" => 180,
      "micro" => 181,
      "para" => 182,
      "middot" => 183,
      "cedil" => 184,
      "sup1" => 185,
      "ordm" => 186,
      "raquo" => 187,
      "frac14" => 188,
      "frac12" => 189,
      "frac34" => 190,
      "iquest" => 191,
      "Agrave" => 192,
      "Aacute" => 193,
      "Acirc" => 194,
      "Atilde" => 195,
      "Auml" => 196,
      "Aring" => 197,
      "AElig" => 198,
      "Ccedil" => 199,
      "Egrave" => 200,
      "Eacute" => 201,
      "Ecirc" => 202,
      "Euml" => 203,
      "Igrave" => 204,
      "Iacute" => 205,
      "Icirc" => 206,
      "Iuml" => 207,
      "ETH" => 208,
      "Ntilde" => 209,
      "Ograve" => 210,
      "Oacute" => 211,
      "Ocirc" => 212,
      "Otilde" => 213,
      "Ouml" => 214,
      "times" => 215,
      "Oslash" => 216,
      "Ugrave" => 217,
      "Uacute" => 218,
      "Ucirc" => 219,
      "Uuml" => 220,
      "Yacute" => 221,
      "THORN" => 222,
      "szlig" => 223,
      "agrave" => 224,
      "aacute" => 225,
      "acirc" => 226,
      "atilde" => 227,
      "auml" => 228,
      "aring" => 229,
      "aelig" => 230,
      "ccedil" => 231,
      "egrave" => 232,
      "eacute" => 233,
      "ecirc" => 234,
      "euml" => 235,
      "igrave" => 236,
      "iacute" => 237,
      "icirc" => 238,
      "iuml" => 239,
      "eth" => 240,
      "ntilde" => 241,
      "ograve" => 242,
      "oacute" => 243,
      "ocirc" => 244,
      "otilde" => 245,
      "ouml" => 246,
      "divide" => 247,
      "oslash" => 248,
      "ugrave" => 249,
      "uacute" => 250,
      "ucirc" => 251,
      "uuml" => 252,
      "yacute" => 253,
      "thorn" => 254,
      "yuml" => 255,


      "fnof" => 402,
      "Alpha" => 913,
      "Beta" => 914,
      "Gamma" => 915,
      "Delta" => 916,
      "Epsilon" => 917,
      "Zeta" => 918,
      "Eta" => 919,
      "Theta" => 920,
      "Iota" => 921,
      "Kappa" => 922,
      "Lambda" => 923,
      "Mu" => 924,
      "Nu" => 925,
      "Xi" => 926,
      "Omicron" => 927,
      "Pi" => 928,
      "Rho" => 929,
      "Sigma" => 931,
      "Tau" => 932,
      "Upsilon" => 933,
      "Phi" => 934,
      "Chi" => 935,
      "Psi" => 936,
      "Omega" => 937,
      "alpha" => 945,
      "beta" => 946,
      "gamma" => 947,
      "delta" => 948,
      "epsilon" => 949,
      "zeta" => 950,
      "eta" => 951,
      "theta" => 952,
      "iota" => 953,
      "kappa" => 954,
      "lambda" => 955,
      "mu" => 956,
      "nu" => 957,
      "xi" => 958,
      "omicron" => 959,
      "pi" => 960,
      "rho" => 961,
      "sigmaf" => 962,
      "sigma" => 963,
      "tau" => 964,
      "upsilon" => 965,
      "phi" => 966,
      "chi" => 967,
      "psi" => 968,
      "omega" => 969,
      "thetasym" => 977,
      "upsih" => 978,
      "piv" => 982,
      "bull" => 8226,
      "hellip" => 8230,
      "prime" => 8242,
      "Prime" => 8243,
      "oline" => 8254,
      "frasl" => 8260,
      "weierp" => 8472,
      "image" => 8465,
      "real" => 8476,
      "trade" => 8482,
      "alefsym" => 8501,
      "larr" => 8592,
      "uarr" => 8593,
      "rarr" => 8594,
      "darr" => 8595,
      "harr" => 8596,
      "crarr" => 8629,
      "lArr" => 8656,
      "uArr" => 8657,
      "rArr" => 8658,
      "dArr" => 8659,
      "hArr" => 8660,
      "forall" => 8704,
      "part" => 8706,
      "exist" => 8707,
      "empty" => 8709,
      "nabla" => 8711,
      "isin" => 8712,
      "notin" => 8713,
      "ni" => 8715,
      "prod" => 8719,
      "sum" => 8721,
      "minus" => 8722,
      "lowast" => 8727,
      "radic" => 8730,
      "prop" => 8733,
      "infin" => 8734,
      "ang" => 8736,
      "and" => 8743,
      "or" => 8744,
      "cap" => 8745,
      "cup" => 8746,
      "int" => 8747,
      "there4" => 8756,
      "sim" => 8764,
      "cong" => 8773,
      "asymp" => 8776,
      "ne" => 8800,
      "equiv" => 8801,
      "le" => 8804,
      "ge" => 8805,
      "sub" => 8834,
      "sup" => 8835,
      "nsub" => 8836,
      "sube" => 8838,
      "supe" => 8839,
      "oplus" => 8853,
      "otimes" => 8855,
      "perp" => 8869,
      "sdot" => 8901,
      "lceil" => 8968,
      "rceil" => 8969,
      "lfloor" => 8970,
      "rfloor" => 8971,
      "lang" => 9001,
      "rang" => 9002,
      "loz" => 9674,
      "spades" => 9824,
      "clubs" => 9827,
      "hearts" => 9829,
      "diams" => 9830,

      "OElig" => 338,
      "oelig" => 339,
      "Scaron" => 352,
      "scaron" => 353,
      "Yuml" => 376,
      "circ" => 710,
      "tilde" => 732,
      "ensp" => 8194,
      "emsp" => 8195,
      "thinsp" => 8201,
      "zwnj" => 8204,
      "zwj" => 8205,
      "lrm" => 8206,
      "rlm" => 8207,
      "ndash" => 8211,
      "mdash" => 8212,
      "lsquo" => 8216,
      "rsquo" => 8217,
      "sbquo" => 8218,
      "ldquo" => 8220,
      "rdquo" => 8221,
      "bdquo" => 8222,
      "dagger" => 8224,
      "Dagger" => 8225,
      "permil" => 8240,
      "lsaquo" => 8249,
      "rsaquo" => 8250,
      "euro" => 8364
    }
    def unknown_entityref(ref)
      # hack to avoid considering &shy;, as it is misused by some blog software (dotclear2)
      # see http://www.cs.tut.fi/~jkorpela/shy.html
      if ref == 'shy'
        handle_data('')
      elsif HTML_ENTITIES.has_key?(ref)
        handle_data([HTML_ENTITIES[ref]].pack('U*'))
      else
        handle_data(ref)
      end
    end
  end
end
