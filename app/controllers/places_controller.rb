class PlacesController < ApplicationController
  layout 'plain'
  before_filter :login_required, :only => [:new, :wizard, :create, :my_places]
  before_filter :find_place, :only => [:wizard, :show, :preview, :photos, :rent, :availability]

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
    if result['stat'] == "ok"
      place = result['place']
      # filter data
      [:place_type, :user, :photos].each do |k|
        place[k] = nil
      end
      response = {:stat => "ok", :place => place}
    else
      response = {:stat => "fail", :err => result['err'], :error_label => error_codes_to_messages(result['err']).join(', ')}
    end
    render :json => response, :layout => false
  end

  def update_currency
    place = Heypal::Place.update(params_with_token(:place).merge(:id => params[:id]))
    render :json => {:currency_sign => currency_sign_of(place['place']['currency'])}
  end

  def publish
    result = Heypal::Place.publish_check(params[:id], current_token)
    if result['stat'] == "ok"
      result = Heypal::Place.publish(params[:id], current_token)
      flash[:notice] = t("places.messages.place_published")
    else
      flash[:error] = t("places.messages.place_publish_error")
    end
    redirect_to preview_place_path(:id => params[:id])
  end

  def unpublish
    place = Heypal::Place.unpublish(params[:id], current_token)
    flash[:notice] = t("places.messages.place_unpublished")
    redirect_to preview_place_path(:id => params[:id])
  end

  def publish_check
    result = Heypal::Place.publish_check(params[:id], current_token)
    if result['stat'] == "ok"
      response = {:stat => "ok"}
    else
      response = {:stat => "fail", :err => result['err'], :error_label => error_codes_to_messages(result['err']).join(', ')}
    end
    render :json => response, :layout => false
  end

  def wizard
    @place = Heypal::Place.find(params[:id], current_token, nil) # no currency conversion

    # filter data
    @place_basic_info = @place
    [:place_type, :user, :photos].each do |k|
      @place_basic_info[k] = nil
    end

    @photos = @place.photos
    @availabilities = Heypal::Availability.find_all({:place_id => @place.to_param}, current_token)
    #@city = Heypal::Geo.find_by_city_id(@place.city_id)
  end

  def preview
    @preview = true
    @comments = Comment.where(:place_id => @place.id).questions

    render(:template => 'places/show', :layout => 'application')
  end

  def show
    @preview = false
    availabilities = Heypal::Availability.find_all({:place_id => @place.to_param}, current_token)

    @availabilities = []
    # FIXME: Implement method in places_helper.rb/cleanup_availabilities
    #availabilities = cleanup_availabilities(availabilities)
    availabilities.each do |a|
        @availabilities 
         {
          'title'  => price_availability_plain_calendar(a, @place),
          'start'  => Date.parse(a['date_start']), 
          'end'    => Date.parse(a['date_end']), 
          'color'  => color_price(a, @place),
          'allDay' => true
        }
    end unless availabilities.blank?

    @comments = Comment.where(:place_id => @place.id).questions
    render :layout => 'application'
  end

  def photos
    @photos = @place.photos
    render :template => 'places/_photo_list', :layout => false
  end

  # default place search2
  def index
    @city = City.find(params[:city]) if params[:city]
    @search = Search::Places.new(current_user, params)
    @results = @search.results

    # if params[:city_id]
    #   @city = City.find(params[:city_id].to_i)
    # elsif params[:city]
    #   @city = City.find(params[:city])
    # end
    # 
    # unless @city
    #   raise "Invalid city"
    # end
    # 
    # # set default city cookie
    # cookies[:pref_city_id] = @city.id
    # 
    # if logged_in?
    #   # save city preference on user profile if logged index
    #   session['current_user'] = current_user.change_preference(:pref_city, @city.id) if @city.id != current_user.pref_city
    # end
    # 
    # #if params[:city]
    # 
    #   check_in  = params[:check_in]  rescue nil
    #   check_out = params[:check_out] rescue nil
    #   page      = params[:page]
    #   alert_params    = { 
    #     'check_in'  => check_in,
    #     'check_out' => check_out,
    #     'sort'      => params[:sort] || 'price_lowest',
    #     'guests'    => '1',
    #     'city'      => @city.id,
    #     'currency'  => get_current_currency,
    #     'per_page'  => 6,
    #     'page'      => page
    #   }
    # 
    # # else
    # #       alert_params = { 
    # #         'city_id'         => params[:city_id],
    # #         'guests'          => params[:guests],
    # #         'check_in'        => params[:check_in],
    # #         'check_out'       => params[:check_out],
    # #         'sort'            => params[:sort],
    # #         'currency'        => params[:currency],
    # #         'min_price'       => params[:min_price],
    # #         'max_price'       => params[:max_price],
    # #         'place_type_ids'  => params['place_type_ids'],
    # #         'page'            => params[:page],
    # #         'per_page'        => 6
    # #       }
    # #     end
    # 
    # @results = Heypal::Place.search(alert_params, current_token)
    # 
    # min, max = Heypal::Geo.get_price_range(@city.id, get_current_currency) #1 is Sing. Line:28 of LookupsHelper
    # if !min.nil? && !max.nil?
    #   @min_price = min
    #   @max_price = max
    # else
    #   @min_price = 0
    #   @max_price = 0
    # end
    # 
    # @alert_params = {
    #   'alert_type'       => 'Place',
    #   'schedule'          => 'daily',
    #   'delivery_method'   => 'email',
    #   'query'             => {
    #     'city_id'         => @city.id,
    #     'guests'          => params['guests'],
    #     'check_in'        => params['check_in'],
    #     'check_out'       => params['check_out'],
    #     'sort'            => params['sort'],
    #     'currency'        => get_current_currency,
    #     'min_price'       => params['min_price'],
    #     'max_price'       => params['max_price'],
    #     'place_type_ids'  => params['place_type_ids']
    #   }
    # }
    # 
    # respond_to do |format|
    #   format.html
    #   format.js { render :partial => 'javascript_place' }
    # end
  end

  # User
  def search
    page = params[:page]
    params.merge!('per_page' => 6, 'page' => page)
    @results = Heypal::Place.search(params, current_token)

    @alert_params = {
      'alert_type'       => 'Place',
      'schedule'          => 'daily',
      'delivery_method'   => 'email',
      'query'             => {
        'city_id'         => params['city_id'],
        'guests'          => params['guests'],
        'check_in'        => params['check_in'],
        'check_out'       => params['check_out'],
        'sort'            => params['sort'],
        'currency'        => params['currency'],
        'min_price'       => params['min_price'],
        'max_price'       => params['max_price'],
        'place_type_ids'  => params['place_type_ids']
      }
    }

    if @results.key?("err")
      render :json => {
        :results       => 0,
        :per_page      => 0,
        :current_page  => 0,
        :total_pages   => 0,
        :place_data    => render_to_string(:_search_results, :locals => {:places => []}, :layout => false),
        :place_filters => ''
      }
    else
      cur_page = @results['current_page'].nil? ? 1 : @results['current_page']
      render :json => {
        :results          => @results['results'], 
        :per_page         => @results['per_page'], 
        :current_page     => cur_page, 
        :place_type_count => @results['place_type_count'],
        :total_pages      => @results['total_pages'], 
        :place_data       => render_to_string(:_search_results, :locals => {:places => @results['places']}, :layout => false),
        :place_filters    => render_to_string(:_place_type_filters, :layout => false),
        :save_search      => render_to_string("alerts/_save_search_form.haml", :locals => {:alert_params => @alert_params}, :layout => false)
      }
    end

  end

  def my_places
    @places = Heypal::Place.my_places(current_token, get_current_currency)
  end

  def favorite_places
    @results = Heypal::Place.favorite_places(current_token, get_current_currency)
  end

  def destroy
    @place = Heypal::Place.delete(params[:id], current_token)
      if @place['stat'] == 'ok'
        flash[:notice] = t("places.messages.place_deleted")
      else
        flash[:error] = t("places.messages.place_deletion_error")
    end
    redirect_to my_places_path
  end

protected

  def find_place
    @place = Heypal::Place.find(params[:id], current_token, get_current_currency)
    @owner = @place.user
  end
end
