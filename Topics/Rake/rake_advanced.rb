
# using rake-compiler, rake/extensiontask
# rake/testtask
describe "rake example @ spyglass_webserver" do
    require 'rake'
    require 'rake/extensiontask'
    require 'rake/testtask'

    desc "Compile the Ragel state machines"
    task :ragel do
        Dir.chdir 'ext/spyglass_parser' do
            target = "parser.c"
            File.unlink target if File.exist? target
            sh "ragel parser.rl -G2 -o #{target}"
            raise "Failed to compile Ragel state machine" unless File.exist? target
        end
    end

    Rake::ExtensionTask.new('spyglass_parser')

    Rake::TestTask.new(:test => :compile) do |t|
        t.libs << 'test'
        t.ruby_opts << '-rubygems'
        t.test_files = FileList['test/*_test.rb']
    end

    require 'rocco/tasks'
    Rocco.make 'doc/'

    desc 'Build documentation'
    task :doc => :rocco
    directory 'doc/'

    desc 'Build documentation and open in your browser for reading'
    task :read => :doc do
        exec 'open doc/lib/spyglass.html'
    end

    desc 'Show the README'
    task :readme do
        exec 'less README.md'
    end

    task :default => :readme
end

task :default => :test
task :test do
    ruby "tests/test1.rb"
    ruby "tests/test2.rb"
end

describe "file&directory&rule" do
    file "index.yaml" => ["hosts.txt", "users.txt", "groups.txt"] do
        ruby "build_index.rb"
    end

    # The file task performs a basic timestamp comparison to decide whether index.yaml needs to be updated.
    # Notice that the dependency can be given as a single string/symbol (as in Listing 11-1) or as an array
    file "html/images" do
        mkdir "html/images"
    end

    # ensure the directory exists, used for subsisute the two above
    directory "html/images"


    rule ".o" => ".c" do |t|
        sh "gcc", "-Wall", "-o", t.name, "-c", t.source
    end

    file "chupacabra.history" => FileList["suck*.story"]
    # matching any globbing patterns but  excluding (by default) those that
    =begin
    •   Contain "CVS" or ".svn"
    •   End in ".bak" or "~"
    •   Are named "core"
    =end
end

describe "rake cool_app" do
    # create every c's correspones o file task
    FileList["*.c"].each do |f|
        file f.sub(/c$/, "o") => f do |t|
            sh "gcc", "-Wall", t.source, "-c", "-o", t.name
        end
    end
    # => to execute the file task. yeah, file task is a subclass for task
    task :default => "cool_app"
    o_files = FileList["*.c"].exclude("main.c").sub(/c$/, "o")
    file "cool_app" => o_files do |t|
        sh "gcc", "-Wall", "-o", t.name, *(t.sources)
    end
    rule ".o" => ".c" do |t|
        sh "gcc", "-Wall", "-o", t.name, "-c", t.source
    end

    def compile(target, sources, *flags)
        sh "gcc", "-Wall", "-Werror", "-O3", "-o", target, *(sources + flags)
    end
    compile(t.name, t.sources)
    compile(t.name, [t.source], "-c")
end

=begin
# Shell, display tasks defined in the current RakeFile 
$ rake –T
rake test  # Run all unit tests
rake perf  # Build a performance profile
=end

desc "Commit the current working copy if all tests pass"
task :commit => :test do
    sh "svn", "commit"
end

# Listing 11-12. Using Rake to Define a Test Task
Rake::TestTask.new do |t|
    t.test_files = FileList["test/tc_*.rb"]
end
