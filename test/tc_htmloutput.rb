#!/usr/bin/ruby -w

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'test')
$:.unshift File.join(File.dirname(__FILE__), 'lib')
$:.unshift File.join(File.dirname(__FILE__), 'test')

require 'test/unit'
require 'feedparser'
require 'feedparser/html-output'

class HTMLOutputTest < Test::Unit::TestCase
  if File::directory?('test/source')
    SRCDIR = 'test/source'
    DSTDIR = 'test/html_output'
  elsif File::directory?('source')
    SRCDIR = 'source'
    DSTDIR = 'html_output'
  else
    raise 'source directory not found.'
  end
  def test_parser
    allok = true
    Dir.foreach(SRCDIR) do |f|
      next if f !~ /.xml$/
      puts "Checking #{f}"
      str = File::read(SRCDIR + '/' + f)
      chan = FeedParser::Feed::new(str)
      chanstr = chan.to_html(false)
      if File::exist?(DSTDIR + '/' + f.gsub(/.xml$/, '.output'))
        output = File::read(DSTDIR + '/' + f.gsub(/.xml$/, '.output'))
        if output != chanstr
          File::open(DSTDIR + '/' + f.gsub(/.xml$/, '.output.new'), "w") do |fd|
            fd.print(chanstr)
          end
          puts "Test failed for #{f}. Try diff -u #{DSTDIR + '/' + f.gsub(/.xml$/, '.output')}{,.new}"
          allok = false
        end
      else
        puts "Missing #{DSTDIR + '/' + f.gsub(/.xml$/, '.output')}. Writing it, but check manually!"
        File::open(DSTDIR + '/' + f.gsub(/.xml$/, '.output'), "w") do |f|
          f.print(chanstr)
        end
        allok = false
      end
    end
    assert(allok)
  end
end
