class PhotosetsController < ApplicationController
  # GET /photosets
  # GET /photosets.xml
  def index
    @photosets = Photoset.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photosets }
    end
  end

  # GET /photosets/1
  # GET /photosets/1.xml
  def show
    @photoset = Photoset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photoset }
    end
  end

  # GET /photosets/new
  # GET /photosets/new.xml
  def new
    @photoset = Photoset.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photoset }
    end
  end

  # GET /photosets/1/edit
  def edit
    @photoset = Photoset.find(params[:id])
  end

  # POST /photosets
  # POST /photosets.xml
  def create
    @photoset = Photoset.new(params[:photoset])

    respond_to do |format|
      if @photoset.save
        format.html { redirect_to(@photoset, :notice => 'Photoset was successfully created.') }
        format.xml  { render :xml => @photoset, :status => :created, :location => @photoset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photoset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photosets/1
  # PUT /photosets/1.xml
  def update
    @photoset = Photoset.find(params[:id])

    respond_to do |format|
      if @photoset.update_attributes(params[:photoset])
        format.html { redirect_to(@photoset, :notice => 'Photoset was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photoset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photosets/1
  # DELETE /photosets/1.xml
  def destroy
    @photoset = Photoset.find(params[:id])
    @photoset.destroy

    respond_to do |format|
      format.html { redirect_to(photosets_url) }
      format.xml  { head :ok }
    end
  end
end
