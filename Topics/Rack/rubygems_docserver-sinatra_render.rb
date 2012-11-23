

# Sinatra 

require File.expand_path(File.dirname(__FILE__) + "/rack_compress")
set :views, Proc.new {File.expand_path(File.dirname(__FILE__) + '/../views')}

require "sinatra/reloader"

class App1 < Sinatra::Base
    register Sinatra::Reloader
    set :someOptions :value | Proc.new {}




# in config,ru , run by rackup config,ru
# 类似一个中间件
# Use the specified Rack middleware
use GemsAndRdocs, :urls => ['/cache', '/doc'], :root => Gem.dir
use Rack::Compress
run RackRubygems.new


# gems_and_rdocs
def initilaize(env)
    @app = app
    @urls = options[:url]
    @file_server = Rack::File.new(options[:root])
end

def call(env)
    path = env["PATH_INFO"]
    can_serve = @urls.any? {|url| path.index(url) == 0}

    if can_serve
        status, headers, response = @file_server.call(env)

    else
        env[""]
        status, headers, response = @app.call(env)
    end
    [status, headers, response]
end


# inner - class Base <self
# 
# 
# Templates are evaluated within the same context as route handlers. 
# Instance variables set in route handlers are directly accessible by templates:

erb "<%= foo %>", :locals => {:foo => "bar"}
erb :index, :layout => !request.xhr?
get '/:id' do
  @foo = Foo.find(params[:id])
  haml '%h1= @foo.name'
end

def erb(template, options={}, locals={})
    render :erb, template, options, locals
end

def render

    scope           = options.delete(:scope)         || self
    # above is something config
    begin
        layout_was = @default_layout
        @default_layout = false
        template = compile_template(engine,data,options,views)
        output = template.render(scope, locals, &block)
    ensure
        @default_layout = layout_was
    end
    if layout
        options = options.merge();
        catch(:layout_missing) { return render(layout_engine, layout, options, locals) {output}}
    end
    # other things
end

def register(*extensions, &block)
    extensions << Module.new(&block) if block_given?
    @extensions += extensions
    extensions.each do |ext|
        extend ext
        ext.registered(self) if ext.respond_to?(:registered)
    end
end

def development?; environment == :development end


set :environment, (ENV['RACK_ENV'] || :development).to_sym

# reloader

# When the extension is registed it extends the Sinatra application
# +klass+ with the modules +BaseMethods+ and +ExtensionMethods+ and
# defines a before filter to +perform+ the reload of the modified files.

# refine the reloading policy with also_reloader and dont_reload
# 
def self.registered(kass)
    @reloader_loaded_in ||={}
    @reloader_loaded_in[klass] = true

    klass.extend BaseMethods
    klass.extend ExtensionMethods

    klass.set(:reloader) {klass.development?}
    klass.set(:reload_templates) {klass.reloader?}

    klass.before do
        if klass.reloader?
            if Reloader.thread_saft?
                Thread.exclusive {Reloader.perform(klass)}
            else
                Reloader.perform(klass)
            end
        end
    end
    klass.set(:inline_templates,klass.app_file) if klass == Sinatra::Application
end

def self.perform(klass)
    Watcher::List.for(klass).updated.each do |watcher|
        klass.set() if watcher.inline_templates?
        watcher.elements.each {|element| klass.deactive(element)}
        $LOADED_FEATURES.delete (watcher.path)
        require watcher.path
        watcher.update
    end
end

# rack::reloader

  class Reloader
    def initialize(app, cooldown = 10, backend = Stat)
      @app = app
      @cooldown = cooldown
      @last = (Time.now - cooldown)
      @cache = {}
      @mtimes = {}

      extend backend
    end

    def call(env)
      if @cooldown and Time.now > @last + @cooldown
        if Thread.list.size > 1
          Thread.exclusive{ reload! }
        else
          reload!
        end

        @last = Time.now
      end

      @app.call(env)
    end

    def reload!(stderr = $stderr)
      rotation do |file, mtime|
        previous_mtime = @mtimes[file] ||= mtime
        safe_load(file, mtime, stderr) if mtime > previous_mtime
      end
    end

    # A safe Kernel::load, issuing the hooks depending on the results
    def safe_load(file, mtime, stderr = $stderr)
      load(file)
      stderr.puts "#{self.class}: reloaded `#{file}'"
      file
    rescue LoadError, SyntaxError => ex
      stderr.puts ex
    ensure
      @mtimes[file] = mtime
    end

    module Stat
      def rotation
        files = [$0, *$LOADED_FEATURES].uniq
        paths = ['./', *$LOAD_PATH].uniq

        files.map{|file|
          next if file =~ /\.(so|bundle)$/ # cannot reload compiled files

          found, stat = figure_path(file, paths)
          next unless found && stat && mtime = stat.mtime

          @cache[file] = found

          yield(found, mtime)
        }.compact
      end

      # Takes a relative or absolute +file+ name, a couple possible +paths+ that
      # the +file+ might reside in. Returns the full path and File::Stat for the
      # path.
      def figure_path(file, paths)
        found = @cache[file]
        found = file if !found and Pathname.new(file).absolute?
        found, stat = safe_stat(found)
        return found, stat if found

        paths.find do |possible_path|
          path = ::File.join(possible_path, file)
          found, stat = safe_stat(path)
          return ::File.expand_path(found), stat if found
        end

        return false, false
      end

      def safe_stat(file)
        return unless file
        stat = ::File.stat(file)
        return file, stat if stat.file?
      rescue Errno::ENOENT, Errno::ENOTDIR, Errno::ESRCH
        @cache.delete(file) and false
      end
    end
  end