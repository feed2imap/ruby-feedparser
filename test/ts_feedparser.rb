#!/usr/bin/ruby -w

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'test')
$:.unshift File.join(File.dirname(__FILE__), 'lib')
$:.unshift File.join(File.dirname(__FILE__), 'test')

require 'tc_feed_parse'
require 'tc_htmloutput'
require 'tc_parser'
require 'tc_textoutput'
require 'tc_textwrappedoutput'
