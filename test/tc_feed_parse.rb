#!/usr/bin/ruby -w

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'feedparser'

# This class includes some basic tests of the parser. More detailed test is
# made by tc_parser.rb
class FeedParserTest < Test::Unit::TestCase
  # From http://my.netscape.com/publish/formats/rss-spec-0.91.html
  def test_parse_rss091_1
    ch = FeedParser::Feed::new <<-EOF
<?xml version="1.0"?>
<!DOCTYPE rss SYSTEM "http://my.netscape.com/publish/formats/rss-0.91.dtd">
<rss version="0.91">
  <channel>
    <language>en</language>
    <description>News and commentary from the cross-platform scripting community.</description>
    <link>http://www.scripting.com/</link>
    <title>Scripting News</title>
    <image>
      <link>http://www.scripting.com/</link>
      <title>Scripting News</title>
      <url>http://www.scripting.com/gifs/tinyScriptingNews.gif</url>
    </image>
  </channel>
</rss>
    EOF
    assert_equal('Scripting News', ch.title)
    assert_equal('http://www.scripting.com/', ch.link)
    assert_equal('News and commentary from the cross-platform scripting community.', ch.description)
    assert_equal([], ch.items)
  end

  def test_parse_rss091_complete
    ch = FeedParser::Feed::new <<-EOF
<?xml version="1.0"?>
<!DOCTYPE rss SYSTEM "http://my.netscape.com/publish/formats/rss-0.91.dtd">
<rss version="0.91">
<channel>
<copyright>Copyright 1997-1999 UserLand Software, Inc.</copyright>
<pubDate>Thu, 08 Jul 1999 07:00:00 GMT</pubDate>
<lastBuildDate>Thu, 08 Jul 1999 16:20:26 GMT</lastBuildDate>
<docs>http://my.userland.com/stories/storyReader$11</docs>
<description>News and commentary from the cross-platform scripting community.</description>
<link>http://www.scripting.com/</link>
<title>Scripting News</title>
<image>
  <link>http://www.scripting.com/</link>
  <title>Scripting News</title>
  <url>http://www.scripting.com/gifs/tinyScriptingNews.gif</url>
  <height>40</height>
  <width>78</width>
  <description>What is this used for?</description>
</image>
<managingEditor>dave@userland.com (Dave Winer)</managingEditor>
<webMaster>dave@userland.com (Dave Winer)</webMaster>
<language>en-us</language>
<skipHours>
  <hour>6</hour><hour>7</hour><hour>8</hour><hour>9</hour><hour>10</hour><hour>11</hour>
</skipHours>
<skipDays>
  <day>Sunday</day>
</skipDays>
<rating>(PICS-1.1 "http://www.rsac.org/ratingsv01.html" l gen true comment "RSACi North America Server" for "http://www.rsac.org" on "1996.04.16T08:15-0500" r (n 0 s 0 v 0 l 0))</rating>
<item>
  <title>stuff</title>
  <link>http://bar</link>
  <description>This is an article about some stuff</description>
</item>
<item>
  <title>second item's title</title>
  <link>http://link2</link>
  <description>aa bb cc
  dd ee ff</description>
</item>
<textinput>
  <title>Search Now!</title>
  <description>Enter your search &lt;terms&gt;</description>
  <name>find</name>
  <link>http://my.site.com/search.cgi</link>
  </textinput>
</channel>
</rss>
    EOF
    assert_equal('Scripting News', ch.title)
    assert_equal('http://www.scripting.com/', ch.link)
    assert_equal('News and commentary from the cross-platform scripting community.', ch.description)
    assert_equal(2, ch.items.length)
    assert_equal('http://bar', ch.items[0].link)
    assert_equal('<p>This is an article about some stuff</p>', ch.items[0].content)
    assert_equal('stuff', ch.items[0].title)
    assert_equal('http://link2', ch.items[1].link)
    assert_equal("<p>aa bb cc\n  dd ee ff</p>", ch.items[1].content)
    assert_equal('second item\'s title', ch.items[1].title)
  end

  def test_getcontent_1
    str =<<-EOF
<content:encoded>&lt;img src="http://planet.gnome.org/heads/hp.png" align="right" alt=""&gt;&lt;p&gt;

What an exhausting week; &lt;a href=&quot;http://freedesktop.org/wiki/Software_2fXDevConf&quot;&gt;XDevConf&lt;/a&gt;
last weekend, LWE, then &lt;a href=&quot;http://fedoraproject.org/fudcon/&quot;&gt;FUDCon&lt;/a&gt;. Really enjoyed
FUDCon today, I thought it went really well. Big thanks to the
organizers. We also had a very productive meeting yesterday with some
of the major external contributors and some Red Hat people; decisions
were reached and action items assigned on a variety of issues.

&lt;/p&gt;

&lt;p&gt;

Since I suck at displays of enthusiasm &lt;a href=&quot;http://www.gnome.org/~seth/&quot;&gt;Seth&lt;/a&gt; is picking up the slack
explaining some of the Red Hat team's work. We also presented some of
this stuff at XDevConf and FUDCon this week.

&lt;/p&gt;

&lt;p&gt;

I think some people didn't catch on to how Sabayon works and what it
does; this thing is not a control panel. It's a sort of live
summarizer of changes you've made to a prototype user account, and
lets you choose the changes to be included in a user profile. The idea
is to take care of any needed hacks as well, for example stripping out
user home directories hardcoded in settings. As far as we can tell
this automates what most admins already do by hand today.  Any cruise
through list archives reveals that admins have a lot of trouble
figuring out which files to extract and what to do with them after
they set up a prototype user the way they want. Even the strongest
mind can be crushed by the GConf and OpenOffice.org tag team.

&lt;/p&gt;

&lt;p&gt;

Colin has been doing a ton of work to create GObject bindings for
D-BUS; looking nice so far, see the &lt;a href=&quot;http://lists.freedesktop.org/archives/dbus/2005-February/thread.html&quot;&gt;list
archives&lt;/a&gt;.

&lt;/p&gt;

&lt;p&gt;

I want to elaborate a bit on one aspect of &quot;next generation rendering&quot;
that we haven't really worked on yet. Everyone is working on the
ability to do OS X or Enlightenment style effects; essentially,
enabling the window manager to use OpenGL and enabling the toolkit to
use Cairo. This gives us drop shadows and minimize animations, and
kills off a bunch of flicker/tearing artifacts. Very good stuff.

&lt;/p&gt;

&lt;p&gt;

However, it doesn't address one huge limitation: themes can only be
designed piecemeal (button, scrollbar, etc.). Graphical elements can't
span multiple widgets. An especially hard case to solve is that
graphical elements can't cover both the window manager frame and
inside the application window.

&lt;/p&gt;

&lt;p&gt;

To make the desktop look really nice, you want the ability to theme a
window (or sub-component thereof) as a whole. This could mean graphics
that span multiple widgets, it could mean moving widgets around, it
could mean changing the spacing between widgets, etc.

&lt;/p&gt;

&lt;pre&gt; ControlPanel -&amp;gt; Frame -&amp;gt; Button -&amp;gt; Rectangle -&amp;gt; Line
&lt;/pre&gt;

</content:encoded>
    EOF
    d = REXML::Document::new(str).root
    puts FeedParser::getcontent(d)
  end
end
