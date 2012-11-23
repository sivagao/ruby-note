
class Url
    include DataMapper::Resource
    property :id, Serial
    property :original, String, :length => 255
    belongs_to :link
end

class Link
    include DataMapper::Resource
    property :identifier, String, :Key => true
    property :created_at, Datetime
    has 1, :url
    has n, :visits

    def self.shorten(original, custom = nil)
        url = 