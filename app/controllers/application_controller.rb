class ApplicationController < ActionController::Base
  protect_from_forgery
  include AuthenticationHelper
  include LookupsHelper
  include RoutesHelper
  include PreferenceHelper
  include AvailabilitiesHelper
  before_filter :instantiate_controller_and_action_names
  before_filter :set_locale
  before_filter :change_preferences
  before_filter :set_current_user
  before_filter :set_subject_for_exception_notification
  before_filter :log_request

  def set_locale
    I18n.locale = get_current_language
  end

  def params_with_token(resource)
    p = params[resource]
    p[:access_token] = current_token
    p
  end

  def change_preferences
    if params.delete(:change_preference)

      if params.key?("locale")
        preference = :locale
        value = Locale.find_by_code(params[preference])
      elsif params.key?("currency")
        preference = :currency
        value = Currency.find_by_currency_code(params[preference])
      elsif params.key?("size_unit")
        preference = :size_unit
        value = params[preference]
      elsif params.key?("speed_unit")
        preference = :speed_unit
        value = params[preference]
      end

      # Set to cookies
      cookie_value = params.delete(preference)
      cookies[preference] = cookie_value

      # TODO: Fix security issue
      # Possible unprotected redirect near line 38: redirect_to(params)
      if logged_in?
        session['current_user'] = current_user.change_preference(preference, value)
        redirect_to params
      else
        redirect_to params.merge(:trigger_signup => true)
      end
    end
  end

  private

  def set_current_user
    Authorization.current_user = current_user
  end

  def instantiate_controller_and_action_names
    @current_action = action_name
    @current_controller = controller_name
  end

  def store_location
    session[:user_return_to] = request.url unless params[:controller] == "sessions"
  end

  def after_sign_in_path_for(user)
    if session[:user_return_to]
      session.delete(:user_return_to)
    elsif user.agent? && Product.manageable_by(user).count.zero?
      new_listing_path
    else
      root_url
    end
  end

  def resource_class
    SiteConfig.product_class
  end

  def set_subject_for_exception_notification
    request.env["exception_notifier.options"] = {:email_prefix => "[#{Rails.env.capitalize}] [#{SiteConfig.site_name}] "}
  end

  def log_request

    if current_user
      user_id    = current_user.id
      user_role  = current_user.role
      user_email = current_user.email
    else
      user_id    = request.cookies["_session_id"]
      user_role  = 'guest'
      user_email = 'guest@guest.com'
    end

    foo = AppLogger.create(
      :url        => request.url.to_s,
      :controller => controller_name,
      :action     => action_name,
      :method     => request.method,
      :params     => params.except(:controller, :action),
      :user_id    => user_id,
      :user_role  => user_role,
      :user_email => user_email
    )
  end
end
