# RR
# RR (Double Ruby) is a test double framework that features a rich selection of double techniques and a terse syntax.
# 
# 
# one of the goal of RR is to make doubles more scannable.
# accomplished by making the double declartion look as much as the actual method invocation as possible
flexmock(User).should_receive(:find).with('42').and_return(jane) # Flexmock
User.should_receive(:find).with('42').and_return(jane) # Rspec
User.expects(:find).with('42').returns {jane} # Mocha
User.should_receive(:find).with('42') {jane} # Rspec using return value blocks
mock(User).find('42') {jane} # RR

# Double Injections
# RR - RR uses method_missing to set your method expectation.
my_object = MyClass.new
mock(my_object).hello
# Mocha
my_mocked_object = mock()
my_mocked_object.expects(:hello)
# Rspec mocks
my_object.should_receive(:hello)

mock(my_object).hello('bob','jane')
my_object.expects(:hello).with("bob","jane")

# using a block to set the return value
mock(my_object).hello('bob', 'jane') {'Hello Bob and Jane'}
my_object.expects(:hello).with('bob','jane').returns('Hello Bob and Jane')

my_mocked_object.hello() -> true



# mock
# mock replaces the method on the object with an expectation and implementation.
# The expectations are a mock will be called with certain arguments a certain number of times (the default is once). You can also set the return value of the method invocation. 
view = controller.template
mock(view).render(:partial => "user_info") {"Information"}
mock(view).render.with_any_args.twice do |*args|
  if args.first == {:partial => "user_info}
    "User Info"
  else
    "Stuff in the view #{args.inspect}"
  end
end

# stub
# stub replaces the method on the object with only an implementation.
# you can still use arguments to differentiate which stub gets invoked.
jane = User.new
bob = User.new
stub(User).find('42') {jane}
stub(User).find('99') {bob}
stub(User).find do |id|
  raise "Unexpected id #{id.inspect} passed to me"
end

# dont_allow aliased with do_not_allow, dont_call, and do_not_call
# dont_allow sets an expectation on the Double that it will never be called.
dont_allow(User).find('42')
User.find('42') # raises a TimesCalledError

# mock.proxy
# MOCK.proxy replaces the method on the object with an expectation, implementation, and also invokes the actual method.
view = controller.template
mock.proxy(view).render(:partial => "right_navigation")
mock.proxy(view).render(:partial => "user_info") do |html|
  html.should include("John Doe")
  "Different html"
end

mock.proxy(User).find('5') do |bob|
  mock.proxy(bob).projects do |projects|
    projects[0..3]
  end
  mock(bob).valid? {false}
  bob
end


# Spies
# adding a doubleinjection to an object + method(done by stub, mock, or dont_allow) causes RR to record any method invocations to
# the object + method.
subject = Object.new
stub(subject).foo(1)
assert_received(subject) {|sub| sub.foo(1)}

# any_instance_of
# which allows to be added to all instances of a class.
any_instance_of(User) do |u|
  stub(u).valid? {false}
end
# or
any_instance_of(User, :valid? => false)
# or
any_instance_of(User, :valid? => lambda {false})


# Block Syntax
# 
script = MyScript.new
mock(script) do
  system("cd #{RAILS_ENV}") {true}
  system("rake foo:bar") {true}
  system("rake baz") {true}
end


# Arugment wildcard matchers
anything
is_a
numeric
boolean
duck_type -> duck_type(:walk, :talk)
ranges
regexps
hash_including
satisfy:
mock(object).foobar(satisfy {|arg| arg.length == 2})
any_times:
mock(object).method_name(anything).times(any_times) {return_value}


# flexmock
require "test/unit"
require "flexmock/test_unit"

class TemperatureSampler
    def initialize(sensor)
        @sensor = sensor
    end

    def average_temp
        total = (0...3).collect {
            @sensor.read_temperature
        }.inject {|i,s| i+s}
        total / 3.0
    end
end

class TestTemperatureSampler < Test::Unit::TestCase
    def test_sensor_can_average_three_temperature_readings
        sensor = flexmock("temp")
        sensor.should_receive(:read_temperature).times(3).and_return(10,12,14)

        sampler = TemperatureSampler.new(sensor)
        assert_equal 12,. sampler.average_temp
    end
end

# Quick Reference
# Creating Mock Objects
# the flexmock method is used to created mocks in various configurations/

# when mocking real objectss(i,e: ),FlexMock will add a handful of mock related methods to the actual object 
should_receive
new_instances
flexmock_get
flexmock_teardown
flexmock_verify
flexmock_received?
flexmock_calls

mock = flexmock(…) { |mock| mock.should_receive(…) }
mock = flexmock(… :spy_on, class_object, …)
mock_model = flexmock(:model, YourModel, …) { |mock| mock.should_receive(…) }

# Expectation Declarators
# Once a mock is craeted. you need to define what the mock should expect to see.

# mock.should_receive(:average).and_return(12)

mock.should_receive(:average).with(12).once

mock.should_receive(:average).with(Integer).
    at_least.twice.at_most.times(10).
    and_return { rand }

mock.should_receive(:average).once.and_return(1)
mock.should_receive(:average).once.and_return(2)
mock.should_receive(:average).and_return(3)
should_receive(meth1 => result1, meth2 => result2, …)
with_any_args

# invocation 
zero_or_more_times
times(n)
at_least
ordered

# return actions
and_return(value)
and_return { |args, …| code … }
and_raise(exception, *args)
and_throw(symbol)
pass_thru { |value| .… }


# Argument Validation
with(/^src/)      will match    f("src_object")
with(/^3\./)      will match    f(3.1415972)


# Creating Partial Mocks


#Spies
#FlexMock supports spy-like mocks as well as the traditional mocks.
# In Test::Unit / MiniTest
class TestDogBarking < Test::Unit::TestCase
  def test_dog
    dog = flexmock(:on, Dog)
    dog.bark("loud")
    assert_spy_called dog, :bark, "loud"
  end
end

dog = flexmock(:on, Dog)

dog.wag(:tail)
dog.wag(:head)

assert_spy_called dog, :wag, :tail
assert_spy_called dog, :wag, :head
assert_spy_called dog, {times: 2}, :wag

assert_spy_not_called dog, :bark
assert_spy_not_called dog, {times: 3}, :wag
