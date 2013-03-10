class ProjectsController < ApplicationController
  include Controllers::Helper

  # GET /projects
  # GET /projects.json
  def index
    project_type = params.delete(:project_type)
    if project_type.nil?
      @projects = Project.all
      history_path = "/"
    else
      @projects = Project.find(:all, :conditions => { :project_type => project_type.to_i })
      history_path = "/?project_type=#{project_type}"
    end
    
    respond_to_ajax_new(:allow_html => true, :history_path => history_path)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    
    collect_result_new
    respond_to_ajax_new(:html_action => "replace_slow", :allow_html => true)
    if @request_type == :html
      params[:action] = "index"
      index
    end
    flush_result_new
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, :notice => 'Project was successfully created.' }
        format.json { render :json => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.json { render :json => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, :notice => 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end
  
  def update_cover_photo
    @project = Project.find(params[:id])
    @project.cover_photo = Photo.new
    @project.cover_photo.create_photo(
      :uploaded_file => params[:project][:cover_photo],
      :name => "project_#{@project.id}_cover_photo",
      "thumbnail_width_large" => Settings.project_cover_photo_width,
      "thumbnail_height_large" => Settings.project_cover_photo_height
      )
      
    if @project.save
      respond_to_ajax(:encapsulate => params.delete(:encapsulate), :target => "#project_#{@project.id}_cover_photo", :html => "<img src='#{@project.cover_photo.thumbnail_url}'>", :track_history => false)
    end
  end
end
