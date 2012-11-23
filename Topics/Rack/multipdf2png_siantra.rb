%w{
    haml
    dm-core
    dm-migrations
    dm-constraints
    carrierwave
    carrierwave/datamapper
}.each {|gem| require gem}

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/pdf2png.sqlite3")
DataMapper::Model.raise_on_save_failure = true

# Pdf modle
class PDFUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :file
  
  process :convert_to_files

    def store_dir
        'uploads'
    end

  def filename
    "#{model.original_filename}.#{model.suffix}" if original_filename
  end
  
  def convert_to_files
    manipulate!(format: 'png') do |img, index|
      image = model.images.new seq: index
      temp = Tempfile.new("image")
      tmp_image = img.write("png:"+ temp.path)      
      image.uploaded = temp
      image.save
      tmp_image
    end
  end
end


class Pdf
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :length => 255
  property :original_filename, String
  property :doc_type, String, :length => 255
  property :suffix, String  
  has n, :images, constraint: :destroy
  mount_uploader :uploaded, PDFUploader, :required => true
end

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :file

    def store_dir
        'uploads'
    end

  def filename
    "img_#{model.pdf.original_filename}_#{model.seq}.png" if original_filename
  end
end

class Image
  include DataMapper::Resource

  property :id, Serial
  property :seq, Integer
  mount_uploader :uploaded, ImageUploader, :required => true
  belongs_to :pdf
end

DataMapper.auto_upgrade!

get "/" do
  haml :upload
end

post "/upload" do
  file = Pdf.create title: params[:title]  
  if params[:uploaded_file] && (tmpfile = params[:uploaded_file][:tempfile])
    file.original_filename, file.suffix = params[:uploaded_file][:filename].split(".")
    file.doc_type = params[:uploaded_file][:type]
    file.uploaded = tmpfile
  end  
  file.save  
  redirect "/"
end

__END__

@@ layout
!!! 1.1
%html{:xmlns => "http://www.w3.org/1999/xhtml"}
  %head
    %title Multi-page PDF upload
  %body
    =yield

@@ upload
%form{action: "/upload", method: 'post', enctype: "multipart/form-data"}
  %div
    %label Title
    %input{type: "text", name: 'title'}
  %div
  %label Select a file
  %input{type: 'file', name: 'uploaded_file'}
  
  %div
    %input{type: "submit", value: "Upload your PDF file"} 
