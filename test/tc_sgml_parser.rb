# encoding: UTF-8

require 'test/unit'
require 'mocha/test_unit'

require 'feedparser/sgml-parser'

class SGMLParserTest < Test::Unit::TestCase

  def test_numerical_charref
    parser = FeedParser::SGMLParser.new
    parser.expects(:unknown_charref).with('215')
    parser.handle_charref('215')
  end

  def test_non_numerical_charref
    parser = FeedParser::SGMLParser.new
    parser.expects(:handle_data).with('amp')
    parser.handle_charref('amp')
  end

end
