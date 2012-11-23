

%form{action: "/upload", method: 'post', enctype: "multipart/form-data"}
  %div
    %label Title
    %input{type: "text", name: 'title'}
  %div
  %label Select a file
  %input{type: 'file', name: 'uploaded_file'}
  
  %div
    %input{type: "submit", value: "Upload your PDF file"} 


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

class Pdf
    include DataMapper::Resource

        mount_uploader :uploaded, PDFUploader, :required => true
    end
end

class PDFUploader < CarrierWave::Uploader
    include CarrierWave::RMagick
    storage :fog

    process :convert_to_files

    def filename

    end

    def convert_to_files
        manipulate!(format: 'png') do |img,index|
            image = model.image.new seq: index
            temp = Tempfile.new("image")
            tmp_image = img.write("png:" + temp)
            

module CarrierWave
    # this module simplifies manipulation with RMagick by providing
    # a set of convenient methods.
    #require 'carrierwave/processing/rmagick'
    # class MyUploader < CarrierWave::Uploader::Base
    #       include CarrierWave::RMagick
    #     end
    #     
    module RMagick
        extend ActiveSupport::Concern

        module ClassMethods
            def convert(format)
                process :convert => format
            end
        end

        def convert(format)
            manipulation!(:format => format)
        end

        # manipulate the image with RMagic.
        # this will load up an image and then 
        # pass each of its frames to the supplied block
        # then save the image to disk
        # 
        # manipulate! do |img, index, options|
        #     options[:write] = {
        #         :quality => 50,
        #         :depth => 8
        #     }
        #     img
        # end
        # # translate
        # image.write do |img|
        #     self.quality = 50
        #     self.depth = 8
        # end
        def manipulate!(options = {}, &block)
            cache_stored_file! if !cached?

            read_block = create_info_block(options[:read])
            image = ::Magick::Image.read(current_path, &read_block)

            frames = if images.size > 1
                list = ::Magick::ImageList.new
                image.each_with_index do |frame, index|
                    processed_frame = if block_given?
                        yield *(frame, index, options).take(block.arity)
                    else
                        frame
                        list << processed_frame if processed_frame
                    end
                    block_given? list : list.append(true)
                else
                    frame = image.first
                    frame
                end
            end
        end

    end
end








