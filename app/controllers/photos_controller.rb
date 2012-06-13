class PhotosController < ApplicationController
  respond_to :js

  before_filter :authenticate_user!, :except => [:create]
  before_filter :find_parent, :except => [:create]

  def create
    @place = @parent = Place.find(params[:place_id])
    @photo = @parent.photos.new(:photo => params[:photo])
    @photo.save
    @photos = @parent.photos

    render :partial => 'photos/list', :layout => false
  end

  def destroy
    @photo = @parent.photos.find(params[:id])
    @photo.destroy
    @place = @parent.reload
    @published = @place.published

    respond_to do |format|
      format.js{ render :template => 'photos/destroy', :layout => false }
    end
  end

  def sort
    @parent.photos.set_positions(params[:photo_ids])

    respond_to do |format|
      format.js{ render :template => 'photos/sort', :layout => false }
    end
  end

  def update
    @photo = @parent.photos.find(params[:id])
    @photo.name = params[:name]
    @photo.save
    respond_to do |format|
      format.js{ render :template => 'photos/update', :layout => false }
    end
  end

  protected

  def find_parent
    @parent = Place.with_permissions_to(:read).find(params[:place_id])
  end
end
