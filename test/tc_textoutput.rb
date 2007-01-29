#!/usr/bin/ruby -w

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'feedparser'
require 'feedparser/text-output'

class TextOutputTest < Test::Unit::TestCase
  if File::directory?('test/source')
    SRCDIR = 'test/source'
    DSTDIR = 'test/text_output'
  elsif File::directory?('source')
    SRCDIR = 'source'
    DSTDIR = 'text_output'
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
      chanstr = chan.to_text(false) # localtime set to false
      if File::exist?(DSTDIR + '/' + f.gsub(/.xml$/, '.output'))
        output = File::read(DSTDIR + '/' + f.gsub(/.xml$/, '.output'))
        if output != chanstr
          File::open(DSTDIR + '/' + f.gsub(/.xml$/, '.output.new'), "w") do |fd|
            fd.print(chanstr)
          end
          puts "Test failed for #{f}."
          puts "  Check: diff -u #{DSTDIR + '/' + f.gsub(/.xml$/, '.output')}{,.new}"
          puts "  Commit: mv -f #{DSTDIR + '/' + f.gsub(/.xml$/, '.output')}{.new,}"
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
