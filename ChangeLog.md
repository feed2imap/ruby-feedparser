# 0.9.4 (25/03/2016)

Bug fixes:

* feedparser: relax exception check for Magic errors; by Eric Wong
* Always sort author list to avoid unecessary invalidation of caches; by Sébastien Dailly

# 0.7 (27/07/2009)

* Handled several creators per feed item
* Fix bug with urls into tag attributes
* Better item categories support
* Reworked text output formatting
* Ignore &shy;, as some blog software (dotclear2) misuse it.

# 0.6 (23/07/2008)

* Moved `to_human_readable` from class Fixnum to class Integer.
* Correctly parse http://www.tbray.org/ongoing/ongoing.atom. Thanks
  to Janico Greifenberg for reporting this.
* String#html2text now takes an additional wrapto parameter, allowing
  to wrap the text to a specified number of chars. Thanks to
  Maxime Petazzoni for the patch.

# 0.5 (26/10/2007)

* Fixed a bug with items with both non-escaped and escaped HTML. Reported,
  then patch provided by Gregory Hartman <gghartma@cs.cmu.edu>.
* In Atom feeds, use the date provided in <updated>, and use it in
  preference to the one in <published> if both are available.
  Closes gna bug #8987.
* "require 'feedparser'" now requires 'feedparser/text-output'. Fixes a bug
  reported by Sebastian Probst Eide.
* Make checks for HTML tags case-insensitive. Broke Dilbert feeds!!
  Reported by Michal Čihař. Closes gna bug #10199.

# 0.4 (01/05/2007)

* Fixed a problem with html entities in the items' titles.
* Date was not fetched for blogspot's atom feeds.
  Patch from Jason Ling <jason.ling@jeyel.com>.
* Tests are now timezone-friendly. (closes GNA bug #8145).
* Much nicer text output.

# 0.3 (01/12/2006)

* Much nicer HTML output
* Fixed a problem with some feeds with broken enclosures (without url)
* Now automatically fixes non-absolute `<a href>` or `<img src>`
* Fixed small parser bugs
* Now displays enclosures in the text and html outputs. Ready for
  podcasting :-)
* Now escape title, creator, subject and category internally. This minor
  fix avoids &amp; stuff in the titles, for example.

* 0.2 (05/06/2006)

* Fixed a problem when parsing some ATOM feeds with <link> without type
  attribute. (Thanks Michal Cihar !)
* FeedParser::Feed and FeedParser::FeedItem now have an xml attribute to
  get the related REXML::Element.
* <enclosure/> support in RSS.

# 0.1 (24/11/2005)

* first public release.
