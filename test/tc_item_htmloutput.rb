require 'test/unit'
require 'feedparser'
require 'feedparser/html-output'


class ItemHTMLOutputTest < Test::Unit::TestCase
  def test_html_with_headers
    feed = FeedParser::Feed.new
    item = FeedParser::FeedItem.new(nil, feed)
    item.title = "Some great title"
    item.content = "Lorem ipsum ..."
    html = item.to_html_with_headers(false)
    assert_match(/Some great title/, html)
    assert_match(/Lorem ipsum .../, html)
    assert_match(/<style type="text\/css">/, html)
  end
end
