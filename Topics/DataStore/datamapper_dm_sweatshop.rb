# Using datapapper sweatshop
# dm-sweatshop

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String
  property :email,    String
  property :password, String
end

User.fixture {{
  :username              => (username = /\w+/.gen),
  :email                 => "#{username}@example.com",
  :password              => (password = /\w+/.gen),
  :password_confirmation => password

  # The /\w+/.gen notation is part of the randexp gem:
  # http://github.com/benburkert/randexp/
}}

User.gen # User.generate

Person.fixture(:valid) {{
  :first_name    => %w(Michael Adam Guiseppe)[rand(3)],
  :last_name     => %w(Smith Black White)[rand(3)],
  :email         => "#{/\w{10}/.gen}@somedomain.info",
  :password_salt => (salt = /\w{20}/.gen),
  :password_hash => Digest::SHA1.hexdigest("#{salt}@--,-`--secret")
}}
Person.make(:valid)
#@make@ to build a model that has not been saved, and @generate!@ to force saving of the model even if it is invalid (it uses @create!@ internally).

#ASSOCIATIONS

DataMapper.setup(:default, "sqlite3::memory:")

class Tweet
  include DataMapper::Resource

  property :id, Serial
  property :message,  String, :length => 140
  property :user_id,  Integer

  belongs_to :user
  has n, :tags, :through => Resource
end

class Tag
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  has n, :tweets, :through => Resource
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String

  has n, :tweets
end

DataMapper.auto_migrate!



User.fix {{
  :username => /\w+/.gen,
  :tweets   => 500.of {Tweet.make}
}}

Tweet.fix {{
  :message => /[:sentence:]/.gen[0..140],
  :tags    => (0..10).of {Tag.make} # (0..10).of(Tag.Pick)
}}

Tag.fix {{
  :name => /\w+/.gen
}}

50.times {Tag.gen} # so for association, you can use pick , not make
# now lets generate 100 users, each with 500 tweets.  Also, the tweet's have 0 to 10 tags!
users = 10.of {User.gen}


#Context
#Context - randomly pick between the available fixtures
Tweet.fix {{
  # a @reply for some user
  :message  => /\@#{User.pick.name} [:sentence:]/.gen[0..140],
  :tags     => (0..10).of {Tag.pick}
}}
Tweet.fix(:conversation){{
    :message => /\@#{(tweet = Tweet.pick(:at_reply)).user.name} [:sentence:]/.gen[0..140],
    :tags => tweet.tags
}}

#Unique values
#wrap your generator in a @unique@ block with no parameters, and the block will be repeatedly executed until it generates a unique value

#Best Practices
#Workflow
# to use dm-sweatshop with test specs is to create a spec/spec_fixutures.rb file, 
# then declare your fixtures in there.
# next, require it in your spec/spec_heler.rb file, after your models have loaded
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

require 'dm-sweatshop'
require File.join(File.dirname(__FILE__), 'spec_fixtures')

