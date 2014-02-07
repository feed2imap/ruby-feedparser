# encoding: UTF-8

require 'test/unit'

require 'feedparser/feedparser'

class Html2TextParserTest < Test::Unit::TestCase

  def test_next_img_index
    parser = FeedParser::HTML2TextParser.new
    assert_equal 'A', parser.next_img_index
    assert_equal 'B', parser.next_img_index
  end

  def test_numerical_entity
    parser = FeedParser::HTML2TextParser.new
    parser.feed('1280&#215;1024')
    parser.close
    assert_equal "1280×1024", parser.savedata
  end

  def test_numerical_entity_large_known
    parser = FeedParser::HTML2TextParser.new
    parser.feed('&#8594;')
    parser.close
    assert_equal "→", parser.savedata
  end

  def test_numerical_entity_large
    parser = FeedParser::HTML2TextParser.new
    parser.feed('&#10000;')
    parser.close
    assert_equal "✐", parser.savedata
  end

  def test_non_numerical_entity
    parser = FeedParser::HTML2TextParser.new
    parser.feed('HTML&amp;CO')
    parser.close
    assert_equal "HTML&CO", parser.savedata
  end

end
