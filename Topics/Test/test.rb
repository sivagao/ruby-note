
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

=begin
$ ruby test_arithmetic.rb
Loaded suite test_arithmetic
Started
.
Finished in 0.002801 seconds.
1 tests, 1 assertions, 0 failures, 0 errors
=end

def test_subtraction
    assert_equal(1.8, 1.9 - 0.1)
end

# - Fixtures - Listing 11-10. A Test Case with a Fixture
# teardown, setup
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
# ts_xx.rb
require "test/unit"
require "tc_arithmetic"
require "tc_linalg"
require "tc_diophantine"

# Listing 11-12. Using Rake to Define a Test Task
Rake::TestTask.new do |t|
    t.test_files = FileList["test/tc_*.rb"]
end


# the simplest test
if foo ! = 'blah'
    puts "i expected 'blah' but foo contains #{{foo}}"
end

# Test::Unit::TestCase
# test_my_func method
# assert 
require "test/unit"
class MyThingieTest < Test::Unit::TestCase
    def test_must_be_empty
        #...
    end
    def test_must_be_awesome
        #...
    end
end

# test_unit_extensions.rb - 
# using must instead of define test_xx functions @ TestCase
module Test::Unit
  # Used to fix a minor minitest/unit incompatibility in flexmock 
  AssertionFailedError = Class.new(StandardError)
  class TestCase
    def self.must(name, &block)
      test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end
  end
end


class MyThingieTest < Test::Unit::TestCase
    must "be empty" do
        #...
    end

    must "be awesome" do
        #...
    end
end

# Test-driven development in action
=begin
>> StyleParser.process("Some <b>bold</b> and <i>italic</i> text")
=> ["Some ", "<b>", "bold", "</b>", " and ", "<i>", "italic", "</i>", " text"]
=end

# the first iteration
class TestInlineStyleParsing < Test::Unit::TestCase
  must "simply return the string if styles are not found" do
    @pdf = Prawn::Document.new
    assert_equal "Hello World", @pdf.parse_inline_styles("Hello World")
  end
end
class Prawn::Document
  def parse_inline_styles(text)
    text
  end
end

# the second iteration
class TestInlineStyleParsing < Test::Unit::TestCase
  must "simply return the string if styles are not found" do
    @pdf = Prawn::Document.new
    assert_equal "Hello World", @pdf.parse_inline_styles("Hello World")
  end
  must "parse italic tags" do
    @pdf = Prawn::Document.new
    assert_equal ["Hello ", "<i>", "Fine", "</i>", " World"],
                  @pdf.parse_inline_styles("Hello <i>Fine</i> World")
  end
  must "parse bold tags" do
    @pdf = Prawn::Document.new
    assert_equal ["Some very ", "<b>", "bold text", "</b>"],
      @pdf.parse_inline_styles("Some very <b>bold text</b>")
  end
end

def parse_inline_styles(text)
  require "strscan"
  sc = StringScanner.new(text)
  output = []
  last_pos = 0
  loop do
    if sc.scan_until(/<\/?[ib]>/)
      pre = sc.pre_match[last_pos..-1]
      output << pre unless pre.empty?
      output << sc.matched
      last_pos = sc.pos
    else
      output << sc.rest if sc.rest?
      break output
    end
  end
  output.length == 1 ? output.first : output
end


must "parse mixed italic and bold tags" do
  @pdf = Prawn::Document.new
  assert_equal ["Hello ", "<i>", "Fine ", "<b>", "World", "</b>", "</i>"],
    @pdf.parse_inline_styles("Hello <i>Fine <b>World</b></i>")
end

class TestInlineStyleParsing < Test::Unit::TestCase
  def setup
    @parser = Prawn::Document::Text::StyleParser
  end
  must "parse italic tags" do
    assert_equal ["Hello ", "<i>", "Fine", "</i>", " World"],
      @parser.process("Hello <i>Fine</i> World")
  end
  must "parse bold tags" do
    assert_equal ["Some very ", "<b>", "bold text", "</b>"],
      @parser.process("Some very <b>bold text</b>")
  end
  must "parse mixed italic and bold tags" do
    assert_equal ["Hello ", "<i>", "Fine ", "<b>", "World", "</b>", "</i>"],
      @parser.process("Hello <i>Fine <b>World</b></i>")
  end
  must "not split out other tags than <i>, <b>, </i>, </b>" do
    assert_equal ["Hello <indigo>Ch", "</b>", "arl", "</b>", "ie</indigo>"],
    @parser.process("Hello <indigo>Ch</b>arl</b>ie</indigo>")
  end
  must "be able to check whether a string needs to be parsed" do
    assert @parser.style_tag?("Hello <i>Fine</i> World")
    assert !@parser.style_tag?("Hello World")
  end
end


module StyleParser
  extend self
  TAG_PATTERN = %r{(</?[ib]>)}
  def process(text)
    text.split(TAG_PATTERN).delete_if{|x| x.empty? }
  end
  def style_tag?(text)
    !!(text =~ TAG_PATTERN)
  end
end

# 字符串方法split，分解符为字符串和正则表达式的区别
=begin
" now's the time".split(' ') #
> ["now's", "the", "time"]
" now's the time".split(/ /) #
> ["", "now's", "", "the", "time"]
=end


class VolumeTest < Test::Unit::TestCase
  must "compute volume based on length, width, and height" do
    # defaults to l=w=h=1
    assert_equal 1, volume
    #when given 1 arg, set l=x, set w,h = 1
    x = 6
    assert_equal x, volume(x)
    # when given 2 args, set l=x, w=y and h=1
    y = 2
    assert_equal x*y, volume(x,y)
    # when given 3 args, set l=x, w=y and h=z
    z = 7
    assert_equal x*y*z, volume(x,y,z)
    # when given a hash, use :length, :width, :height
    assert_equal x*y*z, volume(length: x, width: y, height: z)
  end
end

class VolumeTest < Test::Unit::TestCase
  must "return 1 by default if no arguments are given" do
    # defaults to l=w=h=1
    assert_equal 1, volume
  end
  must "set l=x, set w,h = 1 when given 1 numeric argument" do
    x = 6
    assert_equal x, volume(x)
  end
  must "set l=x, w=y, and h=1 when given 2 arguments" do
    x, y = 6, 2
    assert_equal x*y, volume(x,y)
  end
  must "set l=x, w=y, and h=z when given 3 arguments" do
    x,y,z = 6, 2, 7
    assert_equal x*y*z, volume(x,y,z)
  end
  must "use :length, :width, and :height when given a hash argument" do
    x,y,z = 6, 2, 7
    assert_equal x*y*z, volume(length: x, width: y, height: z)
  end
end

class LockBoxTest < Test::Unit::TestCase
  def setup
    @lock_box = LockBox.new( password: "secret",
                              content: "My Secret Message" )
  end
  must "raise an error when an invalid password is used" do
    assert_raises(LockBox::InvalidPassword) do
      @lock_box.unlock("kitten")
    end
  end
  must "Not raise error when a valid password is used" do
    assert_nothing_raised do
      @lock_box.unlock("secret")
    end
  end
  must "prevent access to content by default" do
    assert_raises(LockBox::UnauthorizedAccess) do
      @lock_box.content
    end
  end
  must "allow access to content when box is properly unlocked" do
    assert_nothing_raised do
      @lock_box.unlock("secret")
      @lock_box.content
    end
  end
end


class LockBox
  UnauthorizedAccess = Class.new(StandardError)
  InvalidPassword    = Class.new(StandardError)
  def initialize(options)
    @locked   = true
    @password = options[:password]
    @content  = options[:content]
  end
  def unlock(pass)
    @password == pass ? @locked = false : raise(InvalidPassword)
  end
  def content
    @locked ? raise(UnauthorizedAccess) : @content
  end
end


require "rake/testtask"
task :default => [:test]
Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = Dir[ "test/test_*.rb" ]
  test.verbose = true
end


class QuestionerTest < Test::Unit::TestCase
  def setup
    @questioner = Questioner.new
  end
  %w[y Y  YeS YES yes].each do |yes|
    must "return true when yes_or_no parses #{yes}" do
      assert @questioner.yes_or_no(yes), "#{yes.inspect} expected to parse as true"
    end
  end
  %w[n N no nO].each do |no|
    must "return false when yes_or_no parses #{no}" do
      assert ! @questioner.yes_or_no(no), "#{no.inspect} expected to parse as false"
    end
  end
  %w[Note Yesterday xyzaty].each do |mu|
    must "return nil because #{mu} is not a variant of 'yes' or 'no'" do
      assert_nil @questioner.yes_or_no(mu), "#{mu.inspect} expected to parse as nil"
    end
  end
end


require "flexmock/test_unit"
class HappinessTest < Test::Unit::TestCase
  def setup
    @questioner = Questioner.new
  end
  must "respond 'Good I'm Glad' when inquire_about_happiness gets 'yes'" do
    stubbed = flexmock(@questioner, :ask => true)
    assert_equal "Good I'm Glad", stubbed.inquire_about_happiness
  end
  must "respond 'That's Too Bad' when inquire_about_happiness gets 'no'" do
    stubbed = flexmock(@questioner, :ask => false)
    assert_equal "That's Too Bad", stubbed.inquire_about_happiness
  end
end

class Questioner
  def inquire_about_happiness
    ask("Are you happy?") ? "Good I'm Glad" : "That's Too Bad"
  end
  def ask(question)
    puts question
    response = gets.chomp
    case(response)
    when /^y(es)?$/i
      true
    when /^no?$/i
      false
    else
      puts "I don't understand."
      ask question
    end
  end
end

class Questioner
  def initialize(in=STDIN,out=STDOUT)
    @input  = in
    @output = out
  end
  def ask(question)
    @output.puts question
    response = @input.gets.chomp
    case(response)
    when /^y(es)?$/i
      true
    when /^no?$/i
      false
    else
      @output.puts "I don't understand."
      ask question
    end
  end
end

class QuestionerTest < Test::Unit::TestCase
  def setup
    @input  = StringIO.new
    @output = StringIO.new
    @questioner = Questioner.new(@input,@output)
    @question   = "Are you happy?"
  end
  ["y", "Y", "YeS", "YES", "yes"].each do |y|
    must "return false when parsing #{y}" do
       provide_input(y)
       assert @questioner.ask(@question), "Expected '#{y}' to be true"
       expect_output "#{@question}\n"
     end
   end
  ["n", "N", "no", "nO"].each do |no|
     must "return false when parsing #{no}" do
       provide_input(no)
       assert !@questioner.ask(@question)
       expect_output "#{@question}\n"
     end
   end
  [["y", true],["n", false]].each do |input,state|
    must "continue to ask for input until given #{input}" do
      provide_input "Note\nYesterday\nxyzaty\n#{input}"
      assert_equal state, @questioner.ask(@question)
      expect_output "#{@question}\nI don't understand.\n"*3 + "#{@question}\n"
    end
  end
  def provide_input(string)
    @input << string
    @input.rewind
  end
  def expect_output(string)
    assert_equal string, @output.string
  end
end

require "flexmock/test_unit"
class QuestionerTest < Test::Unit::TestCase
  def setup
    @input  = flexmock("input")
    @output = flexmock("output")
    @questioner = Questioner.new(@input,@output)
    @question   = "Are you happy?"
  end
  ["y", "Y", "YeS", "YES", "yes"].each do |y|
    must "return false when parsing #{y}" do
       expect_output @question
       provide_input(y)
       assert @questioner.ask(@question), "Expected '#{y}' to be true"
     end
   end
  ["n", "N", "no", "nO"].each do |no|
    must "return false when parsing #{no}" do
      expect_output @question
      provide_input(no)
      assert !@questioner.ask(@question)
    end
  end
  [["y", true], ["n", false]].each do |input, state|
    must "continue to ask for input until given #{input}" do
      %w[Yesterday North kittens].each do |i|
        expect_output @question
        provide_input(i)
        expect_output("I don't understand.")
      end
      expect_output @question
      provide_input(input)
      assert_equal state, @questioner.ask(@question)
    end
  end
  def provide_input(string)
    @input.should_receive(:gets => string).once
  end
  def expect_output(string)
    @output.should_receive(:puts).with(string).once
  end
end




# Test Helpers
require File.dirname(__FILE__) + "/test_helpers"
# Codes that really test.
class PolygonTest < Test::Unit::TestCase
  must "draw each line passed to polygon()" do
    @pdf = Prawn::Document.new
    @pdf.polygon([100,500],[100,400],[200,400])
    line_drawing = observer(LineDrawingObserver)
    assert_equal [[100,500],[100,400],[200,400],[100,500]],
                   line_drawing.points
  end
end
# test_helpers.rb
require "rubygems"
require "test/unit"
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
# $:.unshift(File.join(File.dirname(__FILE__),'..','lib'))
require "prawn"
gem 'pdf-reader', ">=0.7.3"
require "pdf/reader"
def create_pdf
  @pdf = Prawn::Document.new(  left_margin: 0,  right_margin: 0,
                                  top_margin: 0, bottom_margin: 0 )
end
def observer(klass)
  @output = @pdf.render
  obs = klass.new
  PDF::Reader.string(@output,obs)
  obs
end
def parse_pdf_object(obj)
  PDF::Reader::Parser.new(
     PDF::Reader::Buffer.new(StringIO.new(obj)), nil).parse_token
end
puts "Prawn tests: Running on Ruby Version: #{RUBY_VERSION}"



# Custom Assertions
assert bob.current_zone.eql?(Zone.new("4"))
assert_in_zone("4", bob)
module Test
    module Unit
        def assert_in_zone(expected,person)
            assert_block("") do
                person.current_zone.eql?(expected)
            end
        end
    end
end


# Library code with test, which is only runned when the library is executed.
# $0($PROGRAM_NAME)，The name of the top-level Ruby program being executed.
# __FILE__， The name of the current source ﬁle.
class Foo
  ...
end
if __FILE__ == $PROGRAM_NAME
  require "test/unit"
  class TestFoo < Test::Unit::TestCase
    #...
  end
end


# Testing Blog
require "builder"
require "ostruct"
class Blog < OpenStruct
  def entries
    @entries ||= []
  end
  def to_rss
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.rss version: "2.0" do
      xml.channel do
        xml.title       title
        xml.link        "http://#{domain}/"
        xml.description  description
        xml.language    "en-us"
        @entries.each do |entry|
          xml.item do
            xml.title       entry.title
            xml.description entry.description
            xml.author      author
            xml.pubDate     entry.published_date
            xml.link        entry.url
            xml.guid        entry.url
          end
        end
      end
    end
  end
end

require "time"
class BlogTest < Test::Unit::TestCase
  FEED = <<-EOS
  <?xml version="1.0" encoding="UTF-8"?><rss version="2.0"
  ><channel><title>Awesome</title><link>http://majesticseacreature.com/</link>
  <description>Totally awesome</description><language>en-us</language><item>
  <title>First Post</title><description>Nothing interesting</description>
  <author>Gregory Brown</author><pubDate>2008-08-08 00:00:00 -0400</pubDate>
  <link>http://majesticseacreature.com/awesome.html</link>
  <guid>http://majesticseacreature.com/awesome.html</guid></item></channel></rss>
  EOS

  def setup
    @blog = Blog.new
    @blog.title       = "Awesome"
    @blog.domain      = "majesticseacreature.com"
    @blog.description = "Totally awesome"
    @blog.author      = "Gregory Brown"
    entry = OpenStruct.new
    entry.title          = "First Post"
    entry.description    = "Nothing interesting"
    entry.published_date = Time.parse("08/08/2008")
    entry.url            = "http://majesticseacreature.com/awesome.html"
    @blog.entries << entry
  end
  must "have a totally awesome RSS feed" do
    assert_equal FEED.delete("\n"), @blog.to_rss
  end
  must "have a totally awesome RSS feed" do
    assert_equal File.read("expected.rss"), @blog.to_rss
  end
end

require "time"
require "nokogiri"
class BlogTest < Test::Unit::TestCase

  def setup
    @blog = Blog.new
    @blog.title       = "Awesome"
    @blog.domain      = "majesticseacreature.com"
    @blog.description = "Totally awesome"
    @blog.author      = "Gregory Brown"
    entry = OpenStruct.new
    entry.title          = "First Post"
    entry.description    = "Nothing interesting"
    entry.published_date = Time.parse("08/08/2008")
    entry.url            = "http://majesticseacreature.com/awesome.html"
    @blog.entries << entry
    @feed = Nokogiri::XML(@blog.to_rss)
  end

  must "be RSS v 2.0" do
    assert_equal "2.0", @feed.at("rss")["version"]
  end
  must "have a title of Awesome" do
    assert_equal "Awesome", text_at("rss", "title")
  end
  must "have a description of Totally Awesome" do
    assert_equal "Totally awesome", text_at("rss", "description")
  end
  must "have an author of Gregory Brown" do
    assert_equal "Gregory Brown", text_at("rss", "author")
  end
  must "have an entry with the title: First Post" do
    assert_equal "First Post", text_at("item", "title")
  end

  def text_at(*args)
    args.inject(@feed) { |s,r| s.send(:at, r) }.inner_text
  end
end