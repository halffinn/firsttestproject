class PhotosController < ApplicationController
  respond_to :js

  before_filter :authenticate_user!, :except => [:create]
  before_filter :find_parent, :except => [:create]

  def create
    @resource = resource_class.find(params[:listing_id])
    @product = @resource.product
    @photo = Photo.new(:photo => params[:file], :product_id => @product.id)
    if @photo.save
      @photos = @product.photos
      render :partial => 'photos/list', :layout => false
    else
      render :text => 'file error', :status => 500
    end
  end

  def destroy
    @photo = @resource.photos.find(params[:id])
    @photo.destroy
    @resource.reload
    @published = @resource.published

    respond_to do |format|
      format.js{ render :template => 'photos/destroy', :layout => false }
    end
  end

  def sort
    @resource.photos.set_positions(params[:photo_ids])

    respond_to do |format|
      format.js{ render :template => 'photos/sort', :layout => false }
    end
  end

  def update
    @photo = @resource.photos.find(params[:id])
    @photo.name = params[:name]
    @photo.save
    respond_to do |format|
      format.js{ render :template => 'photos/update', :layout => false }
    end
  end

  protected

  def find_parent
    @resource = resource_class.manageable_by(current_user).find(params[:listing_id])
    @product = @resource.product
  end
end
