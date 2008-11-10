#
# Rakefile
#
# See http://docs.rubyrake.org/ to see how to use ``rake'' command.
#
# $Id: Rakefile 61 2005-10-12 09:17:39Z tanaka $
#

require 'rake/clean'
require 'rake/testtask'

require "rake/gempackagetask"
require 'rubygems'

task :default => [:help]

PKG_BUILD   = "RC1"
PKG_VERSION = "1.1.9"


PKG_FILES = FileList[
  "Rakefile", "README", #"ChangeLog", "Releases", "TODO", 
  "setup.rb",
#  "post-install.rb",
#  "bin/*",
#  "doc/*.css", "doc/*.rb",
#  "examples/**/*",
#  "gemspecs/**/*",
  "lib/**/*.rb",
  "lib/**/*.ry",
  "test/**/*",
  "temp/",
  "sample/**/*.rb",
  "sample/**/*.mol",
  "ext/**/*.h", 
  "ext/**/*.c", 
  "ext/**/*.rb",
#  "pkgs/**/*",
#  "redist/*.gem",
#  "scripts/*.rb",
#  "test/**/*"
]

task :doc do |t|
  system "rdoc --main README ./lib README"
end


task :dev => [:compile]
Rake::TestTask.new(:dev) do |t|
  t.libs << File.join('ext')
  t.libs << File.join('lib')
  t.test_files = FileList['test/ts_current.rb']
end

task :test => [:compile]
Rake::TestTask.new(:test) do |t|
  t.libs << File.join('ext')
  t.libs << File.join('lib')
  t.test_files = FileList['test/ts_main.rb']
end

task :light => [:compile]
Rake::TestTask.new(:light) do |t|
  t.libs << File.join('ext')
  t.libs << File.join('lib')
  t.test_files = FileList['test/tc_sssr.rb']
end

task :rm do
  system "rm -rf /usr/local/lib/site_ruby/1.8/chem"
  system "rm /usr/local/lib/site_ruby/1.8/chem.rb"
  system "rm -rf /usr/local/lib/site_ruby/1.8/i386-linux/chem"
end

desc "Prepares for installation"
task :prepare do
  ruby "setup.rb config"
  ruby "setup.rb setup"
end

desc "Installing library"
task :install => [:compile, :prepare] do
  ruby "setup.rb install"
end

task :heavy => [:test]
Rake::TestTask.new(:heavy) do |t|
  t.libs << File.join('ext')
  t.libs << File.join('lib')
  t.test_files = FileList['test/heavy_test*.rb']
end

task :clean do
  cd "ext/" do
    Dir.glob("*.o").each do |file|
      rm file
    end
    Dir.glob("*.bundle").each do |file|
      rm file
    end
  end
end

# BUG!? Need code for testing if racc exist !?
file 'lib/chem/db/smiles/smiparser.rb' => ['lib/chem/db/smiles/smiles.ry'] do
  cd 'lib/chem/db/smiles/' do
    sh "racc smiles.ry -o smiparser.rb"
  end
end

file 'lib/chem/db/iupac/iuparser.rb' => ['lib/chem/db/iupac/iuparser.ry'] do
  cd 'lib/chem/db/iupac/' do
    sh "racc iuparser.ry -o iuparser.rb"
  end
end

file 'lib/chem/db/linucs/linparser.rb' => ['lib/chem/db/linucs/linucs.ry'] do
  cd 'lib/chem/db/linucs/' do
    sh "racc linucs.ry -o linparser.rb"
  end
end

file 'ext/Makefile' => ['ext/extconf.rb', 'ext/subcomp.c'] do
  cd 'ext/'  do
    ruby %{extconf.rb}
  end
end

file "ext/subcomp.#{Config::CONFIG["DLEXT"]}" => ['ext/subcomp.c', 'ext/Makefile'] do
  cd 'ext/'  do
    sh "make"
  end
end


desc "Compiling library"
task :compile => ['lib/chem/db/smiles/smiparser.rb', 'lib/chem/db/iupac/iuparser.rb', 'lib/chem/db/linucs/linparser.rb', "ext/subcomp.#{Config::CONFIG["DLEXT"]}"]

begin
  require 'rake/gempackagetask'

  spec = Gem::Specification.new do |s|
    s.name = 'chemruby'
    s.version = PKG_VERSION
    s.require_path = 'lib'
    s.autorequire = 'chem'
    s.files = PKG_FILES
    s.extensions << 'ext/extconf.rb'  
    s.summary = "A framework program for cheminformatics"
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
    pkg.need_tar_gz = true
    pkg.package_files += PKG_FILES
  end
rescue
  puts 'Install RubyGems to make gem'
end

task :help do |t|
  puts <<EOL

  ChemRuby #{PKG_VERSION}

  To install ChemRuby, you need at least

    * ruby-1.8.2 (or later)
    * Ruby header files (included in original Ruby)
    * C language compilers  (such as gcc)

  If the following modules are installed, ChemRuby will use it.
  You can install them later.

    * RMagick ( You will find how to install them in http://www.chemruby.org)

  == Compiling and Installing

  % rake compile
  % sudo rake install

  or just

  % sudo ruby setup.rb

  == Compiling RDOC

  % rake doc

  == Test

  % rake test

  You will need RMagick and other libraries to  pass all the tests.

EOL
  
end
