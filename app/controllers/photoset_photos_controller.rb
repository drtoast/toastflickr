class PhotosetPhotosController < ApplicationController
  # GET /photoset_photos
  # GET /photoset_photos.xml
  def index
    @photoset_photos = PhotosetPhoto.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photoset_photos }
    end
  end

  # GET /photoset_photos/1
  # GET /photoset_photos/1.xml
  def show
    @photoset_photo = PhotosetPhoto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photoset_photo }
    end
  end

  # GET /photoset_photos/new
  # GET /photoset_photos/new.xml
  def new
    @photoset_photo = PhotosetPhoto.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photoset_photo }
    end
  end

  # GET /photoset_photos/1/edit
  def edit
    @photoset_photo = PhotosetPhoto.find(params[:id])
  end

  # POST /photoset_photos
  # POST /photoset_photos.xml
  def create
    @photoset_photo = PhotosetPhoto.new(params[:photoset_photo])

    respond_to do |format|
      if @photoset_photo.save
        format.html { redirect_to(@photoset_photo, :notice => 'Photoset photo was successfully created.') }
        format.xml  { render :xml => @photoset_photo, :status => :created, :location => @photoset_photo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photoset_photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photoset_photos/1
  # PUT /photoset_photos/1.xml
  def update
    @photoset_photo = PhotosetPhoto.find(params[:id])

    respond_to do |format|
      if @photoset_photo.update_attributes(params[:photoset_photo])
        format.html { redirect_to(@photoset_photo, :notice => 'Photoset photo was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photoset_photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photoset_photos/1
  # DELETE /photoset_photos/1.xml
  def destroy
    @photoset_photo = PhotosetPhoto.find(params[:id])
    @photoset_photo.destroy

    respond_to do |format|
      format.html { redirect_to(photoset_photos_url) }
      format.xml  { head :ok }
    end
  end
end
