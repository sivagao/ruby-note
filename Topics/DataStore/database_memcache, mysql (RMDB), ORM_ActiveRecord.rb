
# using memcache
memcached -d -m 1024 -l 0.0.0.0 -p 11211

cached_obj = Memcache.new('localhost:11211', :readonly => true)
cached_obj.request_timeout = 10
cached_obj = Memcache.new('localhost:11211', "mem2.example.com:11211")

zoo = Memcache.new("localhost:11211")
zoo[:donkeys] = ["siva","siva","siva"*4]
puts zoo[:donkeys].first

hash_of_values = zoo.get_multi(:donkeys, :antelope)

def log_hit
    key = Date.today.strftime("hits -%y%m%d")
    CACHE[key] = 0 unles  CACHE[key]
    CACHE.incr(key,1)
end

session.set("andre",session_data,3600)
session.delete("andre")
session.delete("andre",3600)

# using DataBase RelationShiip
require "dbi"
dbh = DBI.connect("DBI:Mysql:test",'username','password')

["fuge"=>12,"parline"=>13,"siva"=>15].each do |name,stock|
    dbh.do("INSERT INTO sweetmeats (name,stock) VALUES (?,?)", name, stock)
end

query = dbh.prepare("SELECT * FROM sweetmeats")
query.execute
p row while row = query.fetch
query.finish

# more like Ruby style
DBI.connect("DBI:Mysql:test", "username", "password") do |dbh|
  # code from listing 6-4
  dbh.select_all("SELECT * FROM sweetmeats") { |row| p row }
end

# Let's ORM with ActiveRecord
rails diskmon
edit config/database.yml

development:
  adapter: mysql
  database: diskmon_dev
  host: 10.20.30.40
  username: uname
  password: pwd
production:
  adapter: mysql
  database: diskmon
  host: 10.20.30.41
  username: uname
  password: pwd

script/generate migration InitialSchema
a skeleton migration file located at db/migrate/001_initial_schema.rb

class InitialSchema < ActiveRecord::Migration
    def self.up
        create_table :host do |t|
            t.column :name, :string
        end

        create_table :disks do |t|
            t.column :host_id, :integer
            t.column :dev_name, :string
            t.column :mnt_point, :string
            t.column :mb_available, :integer
        end

        create_table :reports do |t|
            t.column :disk_id, :integer
            t.column :created_at, :datetime
            t.column :mb_used, :integer
        end
    end

    def self.down
        drop_table :hosts
        drop_table :disks
        drop_table :reports
    end
end

rake db:migrate

three files named host.rb, disk.rb, and report.rb to be located in app/models
class Host < ActiveRecord::Base
    has_many :disks
end

class Disk < ActiveRecord::Base
    belongs_to :host
    has_many :reports
end

class Report < ActiveRecord::Base
    belongs_to :disk
end

host = Host.create(:name => "slarti")
disk = host.disks.create(:dev_name     => "/dev/disk1s1",
                         :mnt_point    => "/",
                         :mb_available => 80 * 1024)
disk.reports.create(:mb_used => 20 * 1024)
disk.reports.create(:mb_used => 25 * 1024)

script/runner "require 'demo'"


Host.find(:all).each do |host|
  puts "***#{host.name}***"
  puts host.disks.map do |disk|
    [disk.mnt_point, disk.dev_name, disk.mb_available].join("\t")
  end.join("\n")
end

class Disk
  # previous code
  validates_format_of :dev_name, :with => /^\/dev\//
end

root_disks = Disk.find_all_by_mnt_point("/")
total_size = root_disks.inject { |sum, disk| sum + disk.mb_available }
puts "Average root disk size: #{total_size / root_disks.size}"

class Disk
    # previous code

    def usage
        r = reports.find(:first, :order => "created_at DESC")
        r ? report.mb_used : null
    end
    def usage=
        reports.create(:mb_used => value)
    end
end

script/generate migration AddDiskUsageCache

class AddDiskUsageCache < ActiveRecord::Migration
    def self.up
        add_column :disks, :usage, :integer, :default => 0
        Disk.update_all("usage => 0")
    end

    def self.down
        remove_column :disks, :usage
    end
end

rake db:migrate

class Disk
    # previous code
    def usage=(value)
        Disk.transaction(self) do
            reports.create(:mb_used => value)
            self.update_attribute(:usage, value)
        end
    end
end

script/runner "require 'collect_stats'"

hostname = `/bin/hostname`
host = Host.find_or_create_by_name(hostname)
`/bin/df –lm`.each do |line|
  next unless line =~ /^(\/dev\/\S+)\s(.*?)$/
  dev_name = $1
  total, used, available, capacity, mnt_point = $2.split(" ")
  
  disk = host.disks.find_or_create_by_dev_name_and_mnt_point(dev_name, mnt_point)
  t = total.to_i
  disk.update_attribute(:mb_available, t) unless disk.mb_available == t
  
  disk.usage = used.to_i
end

# without mimgration & config file, just using ActiveRecord::Base.establish_connection, Schema.define..
ActiveRecord::Base.establish_connection({
  :database => ":memory:",
  :adapter  => 'sqlite3',
  :timeout  => 500
})

ActiveRecord::Schema.define do
  create_table :authors, :force => true do |t|
    t.string :name
    t.string :nickname
    t.string :first_name
    t.string :last_name
    t.string :phone_number
  end
end

class Book < ActiveRecord::Base

  normalize_attribute  :author

  normalize_attribute  :us_price, :cnd_price, :with => :currency

  normalize_attributes :summary, :with => [ :strip, { :truncate => { :length => 12 } }, :blank ]

  normalize_attributes :title do |value|
    value.is_a?(String) ? value.titleize.strip : value
  end

end

describe boo do
  context 'normalization should not interfere with other hooks and aliases on the attribute assignment' do
    before do
      @book = Book.create!(:title => 'Original Title')
    end

    it 'should still reflect that the attribute has been changed through the call to super' do
      lambda { @book.title = 'New Title' }.should change(@book, :title_changed?).from(false).to(true)
    end
  end

  context 'when another instance of the same saved record has been changed' do
    before do
      @book = Book.create!(:title => 'Original Title')
      @book2 = Book.find(@book.id)
      @book2.update_attributes(:title => 'New Title')
    end

    it "should reflect the change when the record is reloaded" do
      lambda { @book.reload }.should change(@book, :title).from('Original Title').to('New Title')
    end
  end
end