require "sinatra/base"

module Sinatra
    class Application < base

        # the first file that require "sinatra" is the app_file
        set :app_file, caller_files.first || $0
        set :run, Proc.new {File.expand_path($0) == File.expand_path(app_file)}

        if run? && ARGV.any?
            require "optparse"
            OptionParser.new { |op|
                op.on("-p port", "set the port (default is 4567)") {|value| set :port, Integer(value)}
                # other like addr, env, server
                op.on("-x", "turn on the muter lock (default is off)", { set :lock, true})
            }.parse!(ARGV.dup)
        end
    end

    at_exit {Application.run! if $!.nil? && Application.run?}
end

extend Sinatra::Delegator


# base.rb

module Sinatra
    class Base

        class << self

            def run!(options = {})
                set options
                handler = detect_rack_handler
                handler_name = handler.name.gsub(/.*::/,"")
                handler.run self, :Host => bind, :Port => port do |server|
                    unless handler_name =~ /cgi/i
                    end
                    [:INT, :TERM].each {|sig| trap(sig) {quit!(server, handler_name)}}
                    server.threaded = settings.threaded if server.respond_to? :threaded=
                    set :running, true
                    yield server if block_given?
                end


                def detect_rack_handler
                    servers = Array(server)
                    servers.each do |server_name|
                        begin
                            return Rack::Handler.get(server.to_s)
                        rescue LoadError, NameError
                        end
                    end
                    fail "Server handler (#{servers.join(',')}) not found.."
                end

                