require 'test/unit'

require 'feedparser/html2text-parser'

class Html2TextParserTest < Test::Unit::TestCase

  def test_next_img_index
    parser = FeedParser::HTML2TextParser.new
    assert_equal 'A', parser.next_img_index
    assert_equal 'B', parser.next_img_index
  end

end
