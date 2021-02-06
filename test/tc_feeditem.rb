require 'feedparser/feedparser'
require 'test/unit'


class FeedItemTest < Test::Unit::TestCase
  def setup
    @item = FeedParser::FeedItem.new(nil, nil)
  end

  ########################################################################

  def test_link_no_link
    assert @item.link.nil?
  end

  def test_link_basic
    @item.instance_variable_set('@link', 'https://www.example.com/')
    assert_equal "https://www.example.com/", @item.link
  end

  def test_link_path_only
    @item.instance_variable_set('@link', '/foo/bar/')
    assert_equal "/foo/bar/", @item.link
  end

  def test_link_path_only_with_feed_origin
    @item.instance_variable_set('@link', '/foo/bar/')
    feed = FeedParser::Feed.new
    feed.instance_variable_set('@origin', 'https://www.exampleorigin.com')
    @item.instance_variable_set('@feed', feed)
    assert_equal "https://www.exampleorigin.com/foo/bar/", @item.link
  end

  def test_link_full_link_with_feed_origin
    @item.instance_variable_set('@link', 'https://www.exampleorigin.com/foo/bar/')
    feed = FeedParser::Feed.new
    feed.instance_variable_set('@origin', 'https://www.exampleorigin.com')
    @item.instance_variable_set('@feed', feed)
    assert_equal "https://www.exampleorigin.com/foo/bar/", @item.link
  end

  def test_link_with_non_ascii
    @item.instance_variable_set('@link', 'https://www.example.people/☭/')
    assert_equal "https://www.example.people/☭/", @item.link
  end

end
