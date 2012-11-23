
#r cool! test with the rspec, describe, it, context, shoud ==, before(:all) , etc....
require File.dirname(__FILE__) + "/sepc_helper"

describe 'Geo' do
    include Rack::Test::Methods # what does this actually do!

    def app
        Sinatra::Application #单例，以获取geo_ip的sinatra应用
    end

    before(:each) do
        @expected_json_result = {}
    end

    Context "locateme.json" do
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

        end
    end
end