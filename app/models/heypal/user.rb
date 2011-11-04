class Heypal::User < Heypal::Base

  set_resource_path '/users.json'

  @@attributes = %w(first_name last_name gender email password password_confirmation terms oauth_provider oauth_token oauth_uid phone_home phone_mobile phone_work birthdate access_token)
  @@attributes.each { |attr| attr_accessor attr.to_sym }

  define_attribute_methods = @@attributes

  validates :first_name, :last_name, :email, :password, :password_confirmation, :presence => true, :on => :create
  validates :password, :confirmation => true, :on => :create
  validates :terms, :acceptance => true, :on => :create

  class << self
    def create(params = {})
      self.new.unserialize(request('/users/sign_up.json', :post, params))
    end

    def confirm(params = {})
      result = request("/users/confirmation.json?confirmation_token=#{params['confirmation_token']}", :get)
      result['stat'] == 'ok'
    end

    def resend_confirmation(params = {})
      result = request('/users/resend_confirmation.json', :post, params)
      result['stat'] == 'ok'
    end

    def reset_password(params = {})
      result = request('/users/password.json', :post, params)
      result['stat'] == 'ok'
    end

    def confirm_reset_password(params = {})
      result = request('/users/password.json', :put, params)
      result['stat'] == 'ok'
    end

    def show(params = {})
      result = request("/users.json?access_token=#{params['access_token']}", :get, params)
      self.new(result['user'])
    end

    def update(params = {})
      result = request("/users.json?access_token=#{params['access_token']}", :put, params)
      result['stat'] == 'ok'
      #if result['stat'] == 'ok'

      #end
    end

    def list(params = {})
      result = request("/authentications.json?access_token=#{params['access_token']}", :get, params)
    end

  end

  def initialize(params = {})
    deserialize(params)

    self['oauth_token'] = {'provider' => @oauth_provider, 'uid' => @oauth_uid, 'credentials' => {'token' => @oauth_token, 'secret' => ''}}

    @auth_token = self['auth_token']
  end

  def success?
    self['user_id'].present?
  end

  def new_record?
    self['id'].blank? && self.access_token.blank?
  end

  def save
    if new_record?
      @response = self.class.request('/users/sign_up.json', :post, self.to_hash)        
    else
      @response = self.class.request("/users.json?access_token=#{self.access_token}", :put, self.to_hash)
    end

    if @response['stat'] == 'ok'
      return true
    else
      Rails.logger.info @response.inspect
      # TODO: Standardize the error message
      self.errors.add(:base, @response['err'])
      return false
    end
  end

  def fetch!
    result = request("/users/#{self['user_id']}/info.json")
  end

end
