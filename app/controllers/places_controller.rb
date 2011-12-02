class PlacesController < ApplicationController
  layout 'plain'
  before_filter :login_required, :only => [:new, :wizard, :create]
  before_filter :find_place, :only => [:wizard, :show, :preview, :photos]

  def new
    @place = Heypal::Place.new
  end

  def create
    place_params = params[:place]
    place_params[:access_token] = current_token
    place_params[:currency] = get_current_currency

    @place = Heypal::Place.new(place_params)

    if @place.save
      redirect_to wizard_place_path(@place)
    else
      render :action => :new
    end
  end

  def update
    result = Heypal::Place.update(params_with_token(:place).merge(:id => params[:id]))

    render :text => "", :layout => false
  end

  def update_currency
    place = Heypal::Place.update(params_with_token(:place).merge(:id => params[:id]))
    render :json => {:currency_sign => currency_sign_of(place['place']['currency'])}
  end

  def publish
    @place = Heypal::Place.find(params[:id], current_token)
    if @place.attributes_valid?
      result = Heypal::Place.publish(params[:id], current_token)
      flash[:notice] = t(:place_published)
    else
      flash[:error] = t(:place_publish_error)
    end
    redirect_to preview_place_path(:id => params[:id])
  end

  def unpublish
    place = Heypal::Place.unpublish(params[:id], current_token)
    flash[:notice] = t(:place_unpublished)
    redirect_to preview_place_path(:id => params[:id])
  end

  def wizard
    @photos = @place.photos
    @availabilities = Heypal::Availability.find_all({:place_id => @place.to_param}, current_token)
    #@city = Heypal::Geo.find_by_city_id(@place.city_id)
  end

  def preview
    @preview = true
    render(:template => 'places/show', :layout => 'application')
  end

  def show
    @preview = false

    availabilities = Heypal::Availability.find_all({:place_id => @place.to_param}, current_token)

    @availabilities = []
    availabilities.each do |a|
      @availabilities << {'title' => price_availability_plain(a, @place), 'start' => Date.parse(a['date_start']), 'end' => Date.parse(a['date_end']), 'color' => color_price(a, @place)}
    end unless availabilities.blank?

    @comments = Heypal::Comment.find_all({:place_id => @place.to_param}, current_token)

    render :layout => 'application'
  end

  def photos
    @photos = @place.photos
    render :template => 'places/_photo_list', :layout => false
  end

  def upload_photo
    @place = Heypal::Place.find(params[:id], params[:token])

    p = Heypal::Photo.new
    p.place_id = params[:id]
    p.photo_id = Time.now.to_i

    p.photo = params[:file]

    p.save

    photo = {
              :photo => {
                :id => p.photo_id,
                :name => '',
                :place_id => params[:id],
                :filename => params[:Filename],
                :large => p.photo.url(:large, false),
                :medium => p.photo.url(:medium, false),
                :small => p.photo.url(:small, false),
                :original => p.photo.url(:original, false)
              }
            }

    unless @place.photos.nil?
      @photos = @place.photos
    else
      @photos = []
    end

    @photos << photo

    post_params = {:photos => @photos.to_json}

    result = Heypal::Place.update(post_params.merge(:id => params[:id], :access_token => params[:token]))

    # TODO: Refresh (unnecessary since we can get it from the result object. But for the sake of testing today)
    @place = Heypal::Place.find(params[:id], params[:token])
    @photos = @place.photos
    render :template => 'places/_photo_list', :layout => false

  end

  def get_cities
    @cities = Heypal::Geo.get_all_cities(params[:query])
    render :js => @cities.map.collect{|city| [city['name']]}
  end

 #place search
  def index
    params = {"sort" => 'price_lowest', 'max_guests_eq' => '1'}
    @results = Heypal::Place.search(params)
  end

  def search
    @results = Heypal::Place.search(params)
    render :json => {:results => @results['results'], :per_page => @results['per_page'], :current_page => @results['current_page'], :place_type_count => @results['place_type_count'],
      :total_pages => @results['total_pages'], :place_data => render_to_string(:_search_results, :locals => {:places => @results['places']}, :layout => false)}
  end

protected

  def find_place
    @place = Heypal::Place.find(params[:id], current_token)
    @owner = @place['user']
  end
end
