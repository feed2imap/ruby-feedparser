require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake'
require 'find'

# Globals
PKG_NAME = 'ruby-feedparser'
PKG_VERSION = '0.4'

PKG_FILES = [ 'ChangeLog', 'README', 'COPYING', 'LICENSE', 'setup.rb', 'Rakefile']
Find.find('lib/', 'test/', 'tools/') do |f|
	if FileTest.directory?(f) and f =~ /\.svn/
		Find.prune
	else
		PKG_FILES << f
	end
end

task :default => [:package]

Rake::TestTask.new do |t|
	t.libs << "test"
	t.test_files = FileList['test/tc_*.rb']
end

Rake::RDocTask.new do |rd|
  f = []
  Find.find('lib/') do |file|
    if FileTest.directory?(file) and file =~ /\.svn/
      Find.prune
    else
      f << file if not FileTest.directory?(file)
    end
  end
  f.delete('lib/feedparser.rb')
  # hack to document the Feedparser module properly
  f.unshift('lib/feedparser.rb')
  rd.rdoc_files.include(f)
  rd.options << '--all'
  rd.options << '--diagram'
  rd.options << '--fileboxes'
  rd.options << '--inline-source'
  rd.options << '--line-numbers'
  rd.rdoc_dir = 'rdoc'
end

task :doctoweb => [:rdoc] do |t|
   # copies the rdoc to the CVS repository for ruby-feedparser website
	# repository is in $CVSDIR (default: ~/dev/ruby-feedparser-web)
   sh "tools/doctoweb.bash"
end

Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |p|
	p.need_tar = true
  p.need_zip = true
	p.package_files = PKG_FILES
end

# "Gem" part of the Rakefile
begin
	require 'rake/gempackagetask'

	spec = Gem::Specification.new do |s|
		s.platform = Gem::Platform::RUBY
		s.summary = "Ruby library to parse ATOM and RSS feeds"
		s.name = PKG_NAME
		s.version = PKG_VERSION
		s.requirements << 'none'
		s.require_path = 'lib'
		s.autorequire = 'feedparser'
		s.files = PKG_FILES
		s.description = "Ruby library to parse ATOM and RSS feeds"
	end

	Rake::GemPackageTask.new(spec) do |pkg|
		pkg.need_zip = true
		pkg.need_tar = true
	end
rescue LoadError
  puts "Will not generate gem."
end
