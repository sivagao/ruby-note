builder = Builder::XmlMarkup.new(:target=>STDOUT, :indent=>2)
builder.person { |b| b.name("Jim"); b.phone("555-1234") }

>> BasicObject.instance_methods
=> [:==, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__]

class BlankSlate
    class << self
        def hide(name)
            if instance_methods.include?(name) and name !~ /^(_|instance_eavl)/
                @hidden_methods ||= {}
                @hidden_methods[name] = instance)method(name)
                @undef_method name
            end
        end

        def find_hidden_method
        end

        def reveal(name)
            unbound_method = find_hidden_method(name)
            fail "Dont know how to reavl method '#{name}'" unless unbound_method
            define_method(name, unbound_method)
        end
    end
    instance_methods.each {|m| hide(m)}
end


class NewAccountTest < Test::Unit
  def setup
    @account = Account.new
  end
  def test_must_start_with_a_zero_balance
    assert_equal Money.new(0, :dollars), @account.balance
  end
end

describe Account, " when first created" do
  before do
    @account = Account.new
  end
  it "should have a balance of $0" do
    @account.balance.should eql(Money.new(0, :dollars))
  end
end

class Prawn::Document
  def self.generate(file, *args, &block)
    pdf = Prawn::Document.new(*args)
    pdf.instance_eval(&block)
    pdf.render_file(file)
  end
end

Prawn::Document.generate("hello.pdf") do
  text "Hello World"
end

  def generate_pdf
    Prawn::Document.generate("friend.pdf") do |doc|
      doc.text "My best friend is #{full_name}"
    end
  end

class Prawn::Document
  def self.generate(file, *args, &block)
    pdf = Prawn::Document.new(*args)
    block.arity < 1 ? pdf.instance_eval(&block) : block.call(pdf)
    pdf.render_file(file)
  end
end

>> lambda { |x| x + 1 }.arity
=> 1

# Provides the following shortcuts:
#
#    stroke_some_method(*args) #=> some_method(*args); stroke
#    fill_some_method(*args) #=> some_method(*args); fill
#    fill_and_stroke_some_method(*args) #=> some_method(*args); fill_and_stroke
#
def method_missing(id,*args,&block)
  case(id.to_s)
  when /^fill_and_stroke_(.*)/
    send($1,*args,&block); fill_and_stroke
  when /^stroke_(.*)/
    send($1,*args,&block); stroke
  when /^fill_(.*)/
    send($1,*args,&block); fill
  else
    super
  end
end

Prawn::Document.generate("accessors.txt") do
  self.font_size = 10
  text "The font size is now #{font_size}"
end

Prawn::Document.generate("accessors.txt") do
  font_size 10
  text "The font size is now #{font_size}"
end

class Prawn::Document
  def font_size(size = nil)
    return @font_size unless size
    @font_size = size
  end
  alias_method :font_size=, :font_size
end



class SimpleTestHarness
    class << self

        def inherited(base)
            tests << base
        end

        def tests
            @tests ||= []
        end

        def run
            tests.each do |t|
                t.instance_methods.grep(/^test_/).each do |m|
                    test_case = t.new
                    test_case.setup if test_case.respond_to?(test)
                    test_case.send(m)
                end
            end
        end

    end
end

class SimpleTest < SimpleTestHarness
    def setup
        puts "Setting up @ string"
        @string = 'Foo'
    end

    def test_string_must_be_foo
        anwser = (@string == 'Foo' ? 'yes' : 'no')
        puts "@string == 'Foo': " << anwser
    end
    
  def test_string_must_be_bar
    answer = (@string == "bar" ? "yes" : "no")
    puts "@string == 'bar': " << answer
  end

end
