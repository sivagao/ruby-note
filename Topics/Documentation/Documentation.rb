# DOCUMENTATION
# 
=begin
rdoc interprets both code and specialized 
comments in source files and creates nicely formatted documentation from them. It can produce 
HTML pages like the ones you see when running a gem_server (see Chapter 10). It also produces 
documentation for use by ri 
There are three places to choose 
from when using rdoc: the systemwide location, the sitewide location, and your home folder.
=end

class User
    attr_accessor :accepts_messages
    attr_reader :age
    def User.authenticate(login, password)
    end
    def send_message(text)
    end
end

=begin
$ rdoc user.rb
 Some flags I commonly 
use include the following:
•   -a (--all) to include information for all methods, not just public ones
•   -d (--diagram) to generate DOT diagrams of classes and modules (see Chapter 9)
•   -N (--line-numbers) to include line numbers in source code listings
=end


#Basic Comments 
# rdoc’s convention that comments pertinent 
# to a particular element should directly precede that element. 


# Models a user of our network filesystems
class User
    # A boolean determining whether the user can receive messages.
    attr_accessor :accepts_messages
    # The user's age in years.
    attr_reader :age
    # Find a User based on login.
    # Return the User if one was found and if the password matches.
    # Otherwise return nil.
    def User.authenticate(login, password)
    end
    # Send the user a message (if the accepts_messages attribute is set to true).
    def send_message(text)
    end
end


# Listing 11-16. A Quick Tour of Some of the Basic rdoc Markup Facilities
# This is an ordinary paragraph.
# It will end up on a single line.
#   There is a verbatim line here, which will end up by itself.
# This paragraph has single words in *bold*, _italic_ and +typewriter+ styles.
# It then has <b>long stretches of</b> <em>each kind</em> <tt>of style</tt>.
# This text is for 007 only as the double-minus switches off comment processing.
# A double-plus switches it back on.
#++
# This last sentence appears as part of the second paragraph.



# Headings, Separators, and Links

# Separators
# ...and so the man says to him 'no - I asked for pop...corn'.
# ---
# There was a young girl from Nantucket...
# 
# Headings
# === An extremely important heading
# == A fairly important heading
# = This heading is almost feeble
# 
# Links
# http://svn.example.com, ftp://ftp.example.com
# {Send me an e-mail}[mailto:andre@example.com]
# Here's a pretty picture...
# http://www.example.com/puppy.png

# to create Lists

# The hard disks are tracked using the following criteria...
# - capacity
# - rotation speed
# - seek time
# - mean time to failure
# 
# The assessment workflow is handled in three stages... 
# 1. Bob builds the chassis
# 2. Anne installs it in the rack
# 3. Malcolm takes the credit (being in management)

# special command to tune the rdoc engine
module User # :nodoc: all
    class Passwd
    end
end

Rake::RDocTask.new do |t|
    t.main = "README"
    t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    t.options << "--diagram"
end
# t.rdoc_files
# The directory in which to place the generated HTML files (the default being "html")