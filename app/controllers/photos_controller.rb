class PhotosController < ApplicationController
  include Controllers::AwsHelper
  before_filter :authenticate_admin!
  
  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @photos }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @photo = Photo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(params[:photo])
    
    create_photo_args = {}
    create_photo_args[:uploaded_file] = params[:photo_url]
    
    Sebitmin::Application.config.thumbnail_sizes.each do |thumbnail_size|
      thumbnail_width_sym = "thumbnail_width_#{thumbnail_size}"
      if params.key?(thumbnail_width_sym)
        create_photo_args[thumbnail_width_sym] = params[thumbnail_width_sym]
      end
      
      thumbnail_height_sym = "thumbnail_height_#{thumbnail_size}"
      if params.key?(thumbnail_height_sym)
        create_photo_args[thumbnail_height_sym] = params[thumbnail_height_sym]
      end
    end
    @photo.create_photo(create_photo_args)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, :notice => 'Photo was successfully created.' }
        format.json { render :json => @photo, :status => :created, :location => @photo }
      else
        format.html { render :action => "new" }
        format.json { render :json => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, :notice => 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo = Photo.find(params[:id])

    # Destroy s3 objects
    aws_s3_delete(@photo.key)
    Sebitmin::Application.config.thumbnail_sizes.each do |thumbnail_size|
      aws_s3_delete(@photo["thumbnail_key_#{thumbnail_size}"])
    end

    @photo.destroy

    respond_to do |format|
      format.html { redirect_to "/" }
      format.json { head :no_content }
    end
  end
end
