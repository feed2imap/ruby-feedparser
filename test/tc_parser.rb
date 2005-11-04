#!/usr/bin/ruby -w

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'feedparser'

class ParserTest < Test::Unit::TestCase
  if File::directory?('test/parserdata')
    DATADIR = 'test/parserdata'
  elsif File::directory?('parserdata')
    DATADIR = 'parserdata'
  else
    raise 'parserdata directory not found.'
  end
  def test_parser
    allok = true
    Dir.foreach(DATADIR) do |f|
      next if f !~ /.xml$/
#      puts "Checking #{f}"
      str = File::read(DATADIR + '/' + f)
      chan = FeedParser::Feed::new(str)
      chanstr = chan.to_s
      if File::exist?(DATADIR + '/' + f.gsub(/.xml$/, '.output'))
        output = File::read(DATADIR + '/' + f.gsub(/.xml$/, '.output'))
        File::open(DATADIR + '/' + f.gsub(/.xml$/, '.output.new'), "w") do |fd|
          fd.print(chanstr)
        end
        if output != chanstr
          puts "Test failed for #{f}. Try diff -u #{DATADIR + '/' + f.gsub(/.xml$/, '.output')}{,.new}"
          allok = false
        end
      else
        puts "Missing #{DATADIR + '/' + f.gsub(/.xml$/, '.output')}."
        File::open(DATADIR + '/' + f.gsub(/.xml$/, '.output.new'), "w") do |f|
          f.print(chanstr)
        end
      end
    end
    assert(allok)
  end
end
