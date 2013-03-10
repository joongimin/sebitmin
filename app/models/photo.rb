require 'RMagick'

class Photo < ActiveRecord::Base
  include Controllers::AwsHelper
  include Magick
  
  belongs_to :imageable, :polymorphic => true

  def create_photo(args = {})
    if args.key?(:uploaded_file)
      uploaded_file = args[:uploaded_file]
      ext = File.extname(uploaded_file.original_filename)
      org_file = uploaded_file.tempfile
    elsif args.key?(:url)
      url = args[:url]
      ext = File.extname(url)
      org_file = open(url)
    else
      throw "Usage: create_photo(:uploaded_file => $(uploaded_file)) or create_photo(:url => $(url))"
    end
    
    if args.key?(:name)
      name = args[:name]
    else
      name = "photo_#{self.id}"
    end
    
    # Org file
    #f = Tempfile.new([name, ext], Rails.root.join('tmp'), :encoding => 'ascii-8bit')
    f = Tempfile.new([name, ext], Rails.root.join('tmp'))
    begin
      f << org_file.read
    ensure
      f.close
    end
    s3_object = aws_s3_upload(f.path)

    self.url = s3_object.public_url.to_s
    self.key = s3_object.key
    
    Sebitmin::Application.config.thumbnail_sizes.each do |thumbnail_size|
      create_thumbnail(f, thumbnail_size, args)
    end
    
    result = self.save

    f.unlink
    
    result
  end
  
  def create_thumbnail(org_file, thumbnail_size, args = {})
    ext = File.extname(org_file.path)
    thumbnail_width_sym = "thumbnail_width_#{thumbnail_size}"
    if args.key?(thumbnail_width_sym)
      thumbnail_width = args[thumbnail_width_sym].to_f
    else
      thumbnail_width = Settings[thumbnail_width_sym].to_f
    end
  
    thumbnail_height_sym = "thumbnail_height_#{thumbnail_size}"
    if args.key?(thumbnail_height_sym)
      thumbnail_height = args[thumbnail_height_sym].to_f
    else
      thumbnail_height = Settings[thumbnail_height_sym].to_f
    end
  
    img = Magick::Image.read(org_file.path).first
    if img.columns > thumbnail_width or img.rows > thumbnail_height
      org_width = img.columns.to_f
      org_height = img.rows.to_f
      
      width_scale = thumbnail_width.to_f / org_width
      height_scale = thumbnail_height.to_f / org_height
    
      if width_scale > height_scale
        scale = width_scale
      else
        scale = height_scale
      end
      
      if scale > 1.0
        scale = 1.0
      elsif scale < 1.0
        img = img.scale(scale)
      end
      
      img.background_color = "#00000000"
      img = img.extent(thumbnail_width, thumbnail_height, (org_width * scale - thumbnail_width) * 0.5, (org_height * scale - thumbnail_height) * 0.5)
    end
  
    #thumbnail = Tempfile.new(["photo_#{self.id}_thumbnail_#{thumbnail_size}", ext], Rails.root.join('tmp'), :encoding => 'ascii-8bit')
    thumbnail = Tempfile.new(["photo_#{self.id}_thumbnail_#{thumbnail_size}", ext], Rails.root.join('tmp'))
    begin
      thumbnail << img.to_blob
    ensure
      thumbnail.close
    end
    s3_object_thumbnail = aws_s3_upload(thumbnail.path)
    
    self["thumbnail_url_#{thumbnail_size}"] = s3_object_thumbnail.public_url.to_s
    key_field = "thumbnail_key_#{thumbnail_size}"
    if !self[key_field].nil?
      aws_s3_delete(self[key_field])
    end
    self[key_field] = s3_object_thumbnail.key

    thumbnail.unlink
  end
  
  def thumbnail_url(args = {})
    size = args.delete(:thumbnail_size) || :small
    case size
    when :small
      self.thumbnail_url_small
    else
      self.url
    end
  end
end
