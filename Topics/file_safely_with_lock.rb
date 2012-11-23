

File.open("/tmp/foo", "w") do |f|
  f.flock(File::LOCK_EX) # 取得互斥锁，如果未得，等待block，直到获取成功
  f.puts "Locking is the key to ... pun interrupted"
  f.flock(File::LOCK_UN)
end


File.open("/tmp/foo", "w") do |f|
  if f.flock(File::LOCK_EX | File::LOCK_NB) #如果能立即取道锁LOCK_EX，返回true;否则File::LOCK_NB , 执行else中不阻塞时的代码
    f.puts "I want to lock it all up in my pocket"
    f.flock(File::LOCK_UN)
  else warn "Couldn't get a lock - better luck next time"
  end
end


class File
  def File.open_locked(*args)
    File.open(args) do |f|
      begin
        f.flock(File::LOCK_EX)
        result = yield f
      ensure
        f.flock(File::LOCK_UN)
        return result
      end
    end
  end
end
# using the File#open_locked
raw_data = File.open_locked("/tmp/foo") { |f| f.read }


class File
  class << self # 因为此刻添加的是类方法，不能直接使用alias (默认是实例方法)
    alias open_old open
  end
  def File.open(path, mode = "r", perm = 0644) #定义类方法File.open
    File.open_old(path, mode, perm) do |f|
      begin
        f.flock(mode == "r" ? LOCK_SH : LOCK_EX)
        result = yield f
      ensure
        f.flock(File::LOCK_UN)
        return result
      end
    end
  end
end


# 保证原子性
require "filesutils"
require "tempfile"

class File
    def File.open_safely(path)
        result, temp_path = nil, nil
        Tempfile.open("#{$0}-#{path.hash}") do |f|
            result = yield f
            temp_path = f.path
        end
        FileUtils.move(temp_path,path)
        result
    end
end

f.flock(File::LOCK_EX | File::LOCK_NB)


#Creating Temporary Files
# Standard Ruby distribution provides the following useful extension
require 'tempfile'
# With the Tempfile class, the file is automatically deleted on garbage
# collection, so you won't need to remove it, later on.
tf = Tempfile.new('tmp')   # a name is required to create the filename

# If you need to pass the filename to an external program you can use
# File#path, but don't forget to File#flush in order to flush anything
# living in some buffer somewhere.
tf.flush
system("/usr/bin/dowhatever #{tf.path}")

fh = Tempfile.new('tmp')
fh.sync = true                # autoflushes
10.times { |i| fh.puts i }
fh.rewind
puts 'Tmp file has: ', fh.readlines
Printing to Many Filehandles Simultaneously

#----------------------------
filehandles.each do |filehandle|
  filehandle.print stuff_to_print
end
#----------------------------
# NOTE: this is unix specific
IO.popen("tee file1 file2 file3 >/dev/null", "w") do |many|
  many.puts "data"
end
#----------------------------
# (really a Perl issue here, no problem in ruby)
[fh1 fh2 fh3].each {|fh| fh.puts "whatever" }
#----------------------------
# redirect to stdout to use print/puts directly
$stdout = IO.popen("tee file1 file2 file3", "w")
puts "whatever"
$stdout.close
$stdout = STDOUT   # get things back to the way they were
#----------------------------
# create a class/object to encapsulate the behavior in ruby
class MultiDispatcher < BasicObject # inherit from BasicObject in 1.9.x only
 def initialize(targets)
   @targets = targets
 end

 def method_missing(*a,&b)
   @targets.each {|tgt| tgt.send(*a,&b)}
 end
end

md = MultiDispatcher.new [$stdout, $stderr]
4.times {|i| md.printf "%3d\n", i}
md.close



###Flushing Output
output_handle.sync = true
# Please note that like in Perl, $stderr is already unbuffered
#-----------------------------
#!/usr/bin/ruby -w
# seeme - demo stdio output buffering
$stdout.sync = ARGV.size > 0
print "Now you don't see it..."
sleep 2
puts "now you do"
#-----------------------------
$stderr.sync = true
afile.sync = false
#-----------------------------
# assume 'remote_con' is an interactive socket handle,
# but 'disk_file' is a handle to a regular file.
remote_con.sync = true       # unbuffer for clarity
disk_file.sync = false       # buffered for speed
#-----------------------------
require 'socket'
sock = TCPSocket.new('www.ruby-lang.org', 80)
sock.sync = true
sock.puts "GET /en/ HTTP/1.0 \n\n"
resp = sock.read
print "DOC IS: #{resp}\n"