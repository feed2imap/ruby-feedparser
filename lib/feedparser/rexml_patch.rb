require 'feedparser/textconverters'

# Patch for REXML
# Very ugly patch to make REXML error-proof.
# The problem is REXML uses IConv, which isn't error-proof at all.
# With those changes, it uses unpack/pack with some error handling
module REXML
  module Encoding
    alias rexml_decode decode
    def decode(str)
      return str.toUTF8(@encoding)
    end

    alias rexml_encode encode
    def encode(str)
      return str
    end

    alias rexml_encoding= encoding=
    def encoding=(enc)
      return if defined? @encoding and enc == @encoding
      @encoding = enc || 'utf-8'
    end
  end

  class Element
    def children
      @children
    end
  end
end
