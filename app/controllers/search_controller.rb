class SearchController < ApplicationController
  layout 'plain'

  before_filter :authenticate_user!,   :only => [:favorites, :alert]
  before_filter :set_price_unit,       :only => [:show]
  after_filter  :set_city_pref_cookie, :only => [:index]

  def index
    if !request.xhr?
      @city = City.find(params[:city]) if params[:city]
      unless @city
        redirect_to "/#{current_city.slug}"
        return
      end
    end

    @search = searcher.new(params[:search])

    set_price_unit(params[:search][:price_unit]) if params[:search].present?

    @search.currency ||= current_currency
    @search.price_unit ||= current_price_unit
    @search.city_id = @city.id if @city
    @results = @search.results

    @alert = Alert.new
    @alert.search = @search

    respond_to do |format|
      format.js {
        if params[:submitted_action] == 'see_more'
          render :template => "/search/more_results", :layout => false
        else
          render :template => "/search/refresh", :layout => false
        end
      }

      format.html { render :template => "/search/index" }
    end
  end

  def alert
    alert = current_user.alerts.find(params[:alert_id])
    show_alert_search(alert,false)
  end

  def code
    alert = Alert.unscoped.find_by_search_code(params[:search_code])
    show_alert_search(alert)
  end

  def show
    @resource = resource_class.published.find(params[:id])
    @product = @resource.product
    @owner = @resource.user
    if current_user
      @curr_inquiry = Inquiry.where(:user_id => current_user.id, :product_id => @product.id).first
    end
  end

  def favorites
    @results = Favorite.for_user(current_user, resource_class)
  end

  protected

  def searcher
    resource_class.searcher
  end

  private

  def show_alert_search(alert, act_as_new = true)
    @search = alert.search
    @city = City.find(@search.city_id)
    @results = @search.results
    @alert = alert
    if act_as_new
      @alert = alert.dup
      @alert.search = @search
    end
    render 'search/index'
  end

  def set_city_pref_cookie
    cookies[:pref_city_id] = { :value => @city.id, :expires => Time.now + 1.month } if @city.present?
    if logged_in?
      current_user.preferences.city = @city; current_user.preferences.save
    end
  end
end
