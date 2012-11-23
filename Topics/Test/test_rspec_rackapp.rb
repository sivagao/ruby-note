
#r cool! test with the rspec, describe, it, context, shoud ==, before(:all) , etc....
require File.dirname(__FILE__) + "/sepc_helper"

# 不同层级的context（describe）！！！
# before(:each) 和 before(:all)的区别
# 前者是每次它所描述的tests都要运行下，类setUp
# 后者是所有它说描述的tests要使用第一次test的那个before就行了
describe 'Geo' do
    include Rack::Test::Methods # rack测试用，暴露出rack app中last_response,get,等

    def app
        Sinatra::Application #单例，以获取geo_ip的sinatra应用
    end
    before(:each) do
        @expected_json_result = {}
    end

    context "locateme.json" do
        it "returns a result for a real IP" do
            get "/locateme.json",nil, {"REMOTE_ADDR" => '88.11.11.11'}
            JSON.parse(last_response.body).should == @expected_json_result # what the last_response
        end
        it "returns a result for a bad IP" do
            get "/locateme.json"
            JSON.parse(last_response.body).should == {"message" => "your ip could not get"}
        end
    end
    context "/location.json" do
        context "with good params" do
            before(:all) { get '/location.json?ip=89.89.89.22'}
            context "basic" do
                subject {last_response}
                its(:status) {should == 200}
                its(:content_type) {should == 'application/json;charset=utf-89'}
            end
            it "returns a good result" do
                JSON.parse(last_response.body).should == @expected_json_result
            end
        end
        context "with a callback" do
            before(:all) {get '/location.json?ip=87.192.100.212&callback=hey'}
            it "returns a single js function call, with the JSON content as an argument" do
            end
        end
        context "with bad params" do
            # others
        end
    end
end

=begin
The describe method creates an ExampleGroup. Within the block passed to describe you can declare examples using the it method.

Under the hood, an example group is a class in which the block passed to describe is evaluated. 
The blocks passed to it are evaluated in the context of an instance of that class.

declare nested nested groups using the describe or context methods

declare examples within a group using any of it, specify, or example.
=end