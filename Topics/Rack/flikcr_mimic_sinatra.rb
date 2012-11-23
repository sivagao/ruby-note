

post "/after_join" do
    profile = get_user_profile params[:token]
    user = User,find(profile["identifier"])
    if user.new_record?
        photo = profile["email"] ? "htt"
        unless user.update_attribute({})
end

class User
    include DataMapper::Resource

    property :id,   Serial
    #==

    has n, :relationships
    has n, :followers, :through => :relationships, :class_name => "User", :child_key => [:user_id]
    has n, :follows, :through => :relationships, :class_name => "User", :remote_name => :user, :child_key => [:follower_id]

    has n, :albums
    has n, :photos, :through => :albums
    has n, :comments
end

class Relationship
    include DataMapper::Resource

    property :user_id, Integer, :key => true
    property :follower_id, Integer, :key => true

    belongs_to :user, :child_key => [:user_id]
    belongs_to :follower, :class_name => "User", :child_key => [:follower_id]
end

class Album
    include DataMapper:;Resource

    belongs_to :user
    has n, :photos
    belongs_to :cover_photo, :class_name => 'Photo', :child_key => [:cover_photo_id]
end

class Photo

    belongs_to :album
    belongs_to :orignal, :class_name => 'Photo', :child_key => [:photo_id]

    has n, :annotations
    has n, :comments
    has n, :versions, :class_name => "Photo"

    after :save, :save_imgage_s3
    after :destroy, :destroy_image_as

end

class Annotation

    belongs_to :photo
end

class Comment

    belongs_to :user
    belongs_to :photo
end