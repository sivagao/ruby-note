
=begin
in our Rakefile, we create a file task entry named “passwd”. 
This says the goal of this task is to create a file name “passwd”. 
The contents of “passwd” depend on the contents of a file containing a list of our users. Let’s call this file “userlist”.
=end

file "passwd" => ["userlist"] do
    pwds = read_passwords
    users = read_users userlist
    open("passwd", "w") do |outs|
        users.each do |user|
            outs.put "#{user}:#{pwds[user]}:cvs"
        end
    end
end

def read_passwords
    results = {}
    open("/etc/passwd") do |ins|
        ins.each do |line|
            user, pwd, *rest = line.split(':')
            results[user] = pwd
        end
    end
    results
end

def read_users(filename)
  open(filename) do |ins| ins.collect { |line| line.chomp } end
end

=begin
rake passwd
$ ls
=> Rakefile  Rakefile~  passwd  userlist
=end

#cleanup up your act
CLEANS_FILES = FileList['*~']
CLEANS_FILES.clear_exclude
task :clean do
    rm CLEANS_FILES
end

# WHILE the built-in clean task
require 'rake/clean'
CLEAN.include("**/*.tmp")
=begin
If you want to add additional patterns to the clean list, just include them on the CLEAN file list.
”**” in the pattern above. That will recursively search all subdirectories for files ending in ”.temp”.
=end


# equivalent to
filelist = FileList.new
filelist.include(list_of_patterns)


# -*- ruby -*-

require "rake/clean" 
require 'utility'

CLOBBER.include("passwd")

desc "Default task deploys the password files" 
task :default => [:deploy]

desc "Generate the passwd file from the user list" 
file "passwd" => ["userlist"] do
  passwords = read_passwords
  users = read_users("userlist")
  open("passwd", "w") do |outs|
    users.each do |user|
      outs.puts "#{user}:#{passwords[user]}:cvs" 
    end
  end
end

desc "Deploy the generated passwd file to each of the repositories" 
task :deploy

GROUPS = %w(groupa groupb groupc)
GROUPS.each do |group|
  targetdir = "/share/cvs/#{group}/CVSROOT" 
  targetfile = File.join(targetdir, "passwd")

  file targetfile => ["passwd"] do
    mkdir_p targetdir
    cp "passwd", targetfile
  end

  task :deploy => [targetfile]
end
=begin
Each time through the loop, 
:deploy is made to be dependent on each of the target files. 
Rake tasks are additive. 
Each time they are mentioned in a file, 
the dependents and actions are added to the existing task definition
=end

#Rakefile is tailored to specifiying tasks and actions
Tasks