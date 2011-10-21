HeyPalFrontEnd::Application.routes.draw do

  get "publish/index"

  match '/style_guides' => 'style_guides#index'
  match '/style_guides/:action' => 'style_guides'

  resources :products

  resources :users do

    collection do
      get  :confirm
      post :resend_confirmation
      post :reset_password
      get  :reset_password
      get  :confirm_reset_password
    end

  end

  resources :sessions

  match '/signup'       =>  'users#new', :as => :signup
  match '/login'        =>  'sessions#new', :as => :login
  match '/logout'       =>  'sessions#destroy', :as => :logout

  match '/dashboard'    =>  'users#dashboard', :as => :dashboard

  root :to => 'home#index'

end
