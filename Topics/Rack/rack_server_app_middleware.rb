
# server
module Rack
    class Server
        class Options
        end

        def app
            @app ||= begin
                if !::File.exist? options[:config]
                    abort "configuration #{options[:config]} not found"
            end
            app, options = Rack::builder.parse_file(self.options[:config],opt_parse)
            self.options.merge! options
            app
        end

        def start &blk
            if options[:warn
                $-w = true
            end

            if options[:debug]
                $DEBUG = true
                require 'pp'
                p options[:server]
                pp wrapped_app
                pp app
            end

            # touch the wrapped app
            # so the config.ru is loaded before
            # daemonization
            wrapped_app
            daemonize_app if options[:daemonize]

            write_pid if options[:pid]
            trap[:INT] do
                if server.respond_to?(:shutdown)
                    server.shutdown
                else
                    exit
                end
            end
            server.run wrapped_app, options, &blk
        end

        def server
            @_server ||= Rack::Handler.get(options[:server]) || Rack::Handler.default(options)
        end


        def wrapped_app
            @wrapped_app ||= build_app app
        end

        def build_app(app)
            middleware[options[:environment]].reverse_each do |middleware|
                middleware = middleware.call(self) if middleware.respond_to?(:call)
                next unless middleware # if middleware nothing
                klass = middleware.shift
                app = klass.new(app, *middleware)
            end
        end

    end
end

#showexceptions
#which catches all exceptions raised from the app it wraps
# it shows a useful backtrace with the sourcefile and clickable context,
# the whole rack environment and the request data
module Rack
    class ShowExceptions
        CONTEXT = 7

        def initialize(app)
            @app = app
            @template = ERB.new(TEMPLATE)
        end

        def call(env)
            @app.call(env)
        rescue StandardError, LoadError, SyntaxError => e
            exception_string = dump_exception(e)
            env["rack.errors"].puts(exception_string)
            env["rack.errors"].flush

            if prefers_plain_text?(env)
                content_type = "text/plain"
                body = [exception_string]
            else
                content_type = "text/html"
                body = pretty(env,e)
            end

            [
                500,
                {
                    "Content-Type" => content_type,
                    "Content-Length" => Rack::Utils.bytesize(body.join).to_s
                },
                body
            ]
        end

        def pretty(env, exception)
            req = Rack::Request.new(env)

            path = path = (req.script_name + req.path_info).squeeze("/")

            frames = frames = exception.backtrace.map { |line|
                frame = OpenStruct.new
                if line =~ /(.*?):(\d+)(:in `(.*)')?/
                    # sth to do here?!
                end
            }.compat
            [@template.result(binding)]
        end

        def h(obj)
            case obj
            when String
                Utils.escape_html(obj)
            else
                Utils.escape_html(obj.inspect)
            end
        end

        # adapted from Django <djangoproject.com>
        #TEMPLATE = <<'HTML'

        #'HTML'

    end
end

# logger
module Rack
    class Logger
        def initalize(app, level = ::Logger::INFO)
            @app, @level = app, level
        end

        def call(env)
            
        end
    end
end
# file
module Rack
    # Rack::File serves files below the root directory given,
    # according to path info of the Rack request.
    # Rack::File.new("/etc") is used, you can access passwd file at 
    # http://localhost:9292/passwd
    # handlers can detect if bodies are Rack::File, and use mechaniisms
    # like sendfile on the path
    class File
        SEPS = 
        ALLOW_VERBS = %w[GET HEAD]

        attr_accessor: :root, :path, :cache_control
        alias :to_path :path

        def initialize(root, headers = {})
            @root = root
            @headers = headers
        end

        def call(env)
            dup._call(env)
        end

        F = ::File

        def _call(evn)
            unless ALLOW_VERBS.inlclude? env["REQUEST_METHOD"]
                return fail(405, "Method Not Allowed")
            end

            path_info = Utils.unescape(env['PATH_INFO'])
            parts = path_info.split SEPS

            parts.inject(0) do |depth, part|
                case part
                when "","."
                    depth
                when ".."
                    return fail(404, "Not found") if depth -1 < 0
                    depth - 1
                else
                    depth + 1
                end
            end

            @path = F.join(@root, *parts)
            available = begin
                F.file?(@path) && F.readable?(@path)
            rescue SystemCallError
                false
            end

            if available
                serving(env)
            else
                fail(404, "File not found: #{path_info}")
            end
        end

        def serving(env)
            last_modified = F.mtime(@path).httpdate
            return [304,{},[]] if env['HTTP_IF_MODIFIEND_SINCE'] == last_modified
            response = [
                200,
                {
                    "Last-Modified" => last_modified,
                    "Content-Type" => Mine.mine_type(F.extname(@path), 'text/plain')
                },
                env["REQUEST_METHOD"] == 'HEAD' ? [] : self
            ]

            @headers.each { |field, content|
                response[1][field] = content
            } if @headers

            # expect the /proc files, or something like that
            # otherwise we have to figure it out by reading 
            # the whole file into memory
            size = F.size?(@path) || Utils.bytesize(F.read(@path))
            ranges = Rack::Utils.byte_ranges(env, size)
            if ranges.nil? || ranges.length > 1
                response[0] = 200
                @range = 0..size - 1
            elsif range.empty?
            else
            end

            #partial content
            @range = range[0]
            response[0] = 206
            response[1]["Content-Range"] = "bytes #{@range.begin}-#{@range}"
        end
    end
end