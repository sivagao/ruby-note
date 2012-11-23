# Using dm-is-versioned
# enabling simple versioning of model

#When a model is versioned, and updated, instead of the previous version being lost in the mists of time, it is saved in a subsidiary table, so that it can be restored later if needed.

class Post
  include DataMapper::Resource

  property :id,         Serial
  property :title,      String
  property :body,       Text
  property :updated_at, DateTime

  is_versioned :on => :updated_at

  ## this syntax also works
  # is :versioned, :on => :updated_at
end

post = Post.create(:title => 'A versioned Post title', :body => "A versioned Post body")
# automatically saved
post.title = "An updated & versioned Post title"
post.save

old_post = post.versions.first
# the #versions method returns an array by default.

# Make sure the versioned trigger has a value
# only the field which be indicated at is_versioned on method change can trigger the version action
property :updated_at, DateTime
is_versioned :on => :updated_at
# using the dm-timestamps gem, which automatically updates the :updated_at attribute
timestamps :at
# or a callback method, that updates the value before save
before(:save) { self.updated_at = Time.now }

