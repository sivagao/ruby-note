
ActiveRecord::Schema.define do

    create_table "users", :force => true do |t|
        t.column "name", :text
        t.column "salary", :integer, :default => 70000
        t.column "created_at", :datetime
        t.column "updated_at" :datetime
        t.column "type", :text
    end

    create_table "projects", :force => true do |t|
        t.column "name", :text
    end

    create_table "developers_projects", :id => false, :force => true do |t|
        t.column "developer_id", :integer, :null => false
        t.column "project_id", :integer, :null => false
        t.column "joined_on", :date
        t.column "access_level", :integer, :default => 1
    end

    create_table "topics", :force => true do |t|
        t.column "project_id", :integer
        t.column "title", :string
        t.column "subtitle", :string
        t.column "content", :text
        t.column "created_at", :datetime
        t.column "updated_at", :datetime
    end

    create_table "replies", :force => true do |t|
        t.column "content", :text
        t.column "created_at", :datetime
        t.column "updated_at", :datetime
        t.column "topic_id", :integer
    end

end

# all the model defined file

class Topic < ActiveRecord::Base
    has_many :replies, :dependent => :destory, :order => ""
    belongs_to :project

    scope :mentions_activerecord, :conditions => ['topics.title LIKE ?','%ActiveRecord%']
    scope :distinct, :select => "DISTINCT #{table_name}.*"
end

class Reply < ActiveRecord::Base
    belongs_to :topic, :include => [:repies]

    scope :recent,
        :conditions => ['replies.created_at >?', 15.minutes.ago],
        :order => 'replies.created_at DESC'

    validates_presece_of :content
end

class User < ActiveRecord::Base
end

class Admin < User
  has_many :companies, :finder_sql => 'SELECT * FROM companies'
end

class Project < ActiveRecord::Base
  has_and_belongs_to_many :developers, :uniq => true
  
  has_many :topics
    # :finder_sql  => 'SELECT * FROM topics WHERE (topics.project_id = #{id})',
    # :counter_sql => 'SELECT COUNT(*) FROM topics WHERE (topics.project_id = #{id})'
  
  has_many :replies, :through => :topics do
    def only_recent(params = {})
      scoped.where(['replies.created_at > ?', 15.minutes.ago])
    end
  end

  has_many :unique_replies, :through => :topics, :source => :replies, :uniq => true
end

class Developer < User
  has_and_belongs_to_many :projects, :include => :topics, :order => 'projects.name'

  def self.with_poor_ones(&block)
    with_scope :find => { :conditions => ['salary <= ?', 80000], :order => 'salary' } do
      yield
    end
  end

  scope :poor, :conditions => ['salary <= ?', 80000], :order => 'salary'

  def self.per_page() 10 end
end


