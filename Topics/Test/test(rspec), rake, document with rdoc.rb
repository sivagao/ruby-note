


task :default => :test
task :test do
  ruby "tests/test1.rb"
  ruby "tests/test2.rb"
end


file "index.yaml" => ["hosts.txt", "users.txt", "groups.txt"] do
  ruby "build_index.rb"
end

# The file task performs a basic timestamp comparison to decide whether index.yaml needs to be updated.
# Notice that the dependency can be given as a single string/symbol (as in Listing 11-1) or as an array
file "html" do
  mkdir "html"
end
file "html/images" do
  mkdir "html/images"
end

# ensure the directory exists, used for subsisute the two above
directory "html/images"


rule ".o" => ".c" do |t|
  sh "gcc", "-Wall", "-o", t.name, "-c", t.source
end

files = FileList["html/**/*.html"]
file "chupacabra.history" => FileList["suck*.story"]
# matching any globbing patterns but  excluding (by default) those that
=begin
•   Contain "CVS" or ".svn"
•   End in ".bak" or "~"
•   Are named "core"
=end

# create every c's correspones o file task
FileList.["*.c"].each do |f|
  file f.sub(/c$/, "o") => f do |t|
    sh "gcc", "-Wall", t.source, "-c", "-o", t.name
  end
end


task :default => "cool_app"
o_files = FileList["*.c"].exclude("main.c").sub(/c$/, "o")
file "cool_app" => o_files do |t|
  sh "gcc", "-Wall", "-o", t.name, *(t.sources)
end
rule ".o" => ".c" do |t|
  sh "gcc", "-Wall", "-o", t.name, "-c", t.source
end
# rake cool_app => to execute the file task. yeah, file task is a subclass for task

def compile(target, sources, *flags)
  sh "gcc", "-Wall", "-Werror", "-O3", "-o", target, *(sources + flags)
end
compile(t.name, t.sources)
compile(t.name, [t.source], "-c")

# Shell, display tasks defined in the current RakeFile 
$ rake –T
rake test  # Run all unit tests
rake perf  # Build a performance profile


# Using Test with Test:Unit
require "test/unit"
class ArithmeticTest < Test::Unit::TestCase
  def test_addition
    assert 1 + 1 == 2
  end
end

assert_equal(2, 1 + 1)
=begin
Other assertion methods include assert_nil(obj), assert_kind_of(klass, obj), 
assert_respond_to(obj, message), assert_match(regexp, string), and flunk. Take a look at 
ri Test::Unit::Assertions for more detail.
=end

$ ruby test_arithmetic.rb
Loaded suite test_arithmetic
Started
.
Finished in 0.002801 seconds.
1 tests, 1 assertions, 0 failures, 0 errors

def test_subtraction
  assert_equal(1.8, 1.9 - 0.1)
end

# - Fixtures - Listing 11-10. A Test Case with a Fixture
require "test/unit"
class RemoteHostTest < Test::Unit::TestCase
  def setup
    @session = RemoteHost.new("testserver.example.org")
  end
  def teardown
    @session.close
  end
  def test_echo
    assert_equal("ping", @session.echo("ping").stdout)
  end
end

# testsuite, just include the testcase file.
require "test/unit"
require "tc_arithmetic"
require "tc_linalg"
require "tc_diophantine"

# Listing 11-12. Using Rake to Define a Test Task
Rake::TestTask.new do |t|
  t.test_files = FileList["test/tc_*.rb"]
end

desc "Commit the current working copy if all tests pass"
task :commit => :test do
  sh "svn", "commit"
end

# DOCUMENTATION
# 
=begin
rdoc interprets both code and specialized 
comments in source files and creates nicely formatted documentation from them. It can produce 
HTML pages like the ones you see when running a gem_server (see Chapter 10). It also produces 
documentation for use by ri 
There are three places to choose 
from when using rdoc: the systemwide location, the sitewide location, and your home folder.
=end

class User
  attr_accessor :accepts_messages
  attr_reader :age
  def User.authenticate(login, password)
  end
  def send_message(text)
  end
end

=begin
$ rdoc user.rb
 Some flags I commonly 
use include the following:
•   -a (--all) to include information for all methods, not just public ones
•   -d (--diagram) to generate DOT diagrams of classes and modules (see Chapter 9)
•   -N (--line-numbers) to include line numbers in source code listings
=end


#Basic Comments 
# rdoc’s convention that comments pertinent 
# to a particular element should directly precede that element. 


# Models a user of our network filesystems
class User
  # A boolean determining whether the user can receive messages.
  attr_accessor :accepts_messages
  # The user's age in years.
  attr_reader :age
  # Find a User based on login.
  # Return the User if one was found and if the password matches.
  # Otherwise return nil.
  def User.authenticate(login, password)
  end
  # Send the user a message (if the accepts_messages attribute is set to true).
  def send_message(text)
  end
end


# Listing 11-16. A Quick Tour of Some of the Basic rdoc Markup Facilities
# This is an ordinary paragraph.
# It will end up on a single line.
#   There is a verbatim line here, which will end up by itself.
# This paragraph has single words in *bold*, _italic_ and +typewriter+ styles.
# It then has <b>long stretches of</b> <em>each kind</em> <tt>of style</tt>.
# This text is for 007 only as the double-minus switches off comment processing.
# A double-plus switches it back on.
#++
# This last sentence appears as part of the second paragraph.



# Headings, Separators, and Links

# Separators
# ...and so the man says to him 'no - I asked for pop...corn'.
# ---
# There was a young girl from Nantucket...
# 
# Headings
# === An extremely important heading
# == A fairly important heading
# = This heading is almost feeble
# 
# Links
# http://svn.example.com, ftp://ftp.example.com
# {Send me an e-mail}[mailto:andre@example.com]
# Here's a pretty picture...
# http://www.example.com/puppy.png

# to create Lists

# The hard disks are tracked using the following criteria...
# - capacity
# - rotation speed
# - seek time
# - mean time to failure
# 
# The assessment workflow is handled in three stages... 
# 1. Bob builds the chassis
# 2. Anne installs it in the rack
# 3. Malcolm takes the credit (being in management)

# special command to tune the rdoc engine
module User # :nodoc: all
  class Passwd
  end
end

Rake::RDocTask.new do |t|
  t.main = "README"
  t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  t.options << "--diagram"
end
# t.rdoc_files
# The directory in which to place the generated HTML files (the default being "html")

