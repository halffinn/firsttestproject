module PreferenceHelper

  def current_city
    Preferences.current_city(current_user, cookies)
  end
  
  def current_city_from_user_pref_or_cookie
    Preferences.current_city_from_user_pref_or_cookie(current_user, cookies)
  end

  def current_currency
    Preferences.current_currency(current_user, cookies)
  end

  def get_current_language
    Preferences.current_language(current_user, cookies)
  end

  def get_current_size_unit
    Preferences.current_size_unit(current_user, cookies)
  end

  def get_current_speed_unit
    Preferences.current_speed_unit(current_user, cookies)
  end

  def current_price_unit
    Preferences.current_price_unit(current_user, session)
  end

  def set_price_unit(new_unit = nil)
    new_unit = params[:price_unit] if new_unit.nil?
    return unless new_unit.present? and SiteConfig.price_units.include? new_unit.to_sym
    session[:pref_price_unit] = new_unit
    if logged_in?
      session['current_user'] = current_user.change_preference(:price_unit, new_unit)
    end
  end

  #TODO Remove this
  #Used in the Properties.new
  def get_size_unit_backend_compatible
    Preferences.current_size_unit_backend_compatible(current_user, cookies)
  end
end
