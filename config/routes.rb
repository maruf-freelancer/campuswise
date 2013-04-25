Campuswise::Application.routes.draw do
  get "password_resets/create"

  get "password_resets/edit"

  get "password_resets/update"

  root :to => "static#home"
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match "home"     => "static#home"

  match '/find' => 'static#public_find_books'
  
  resources :users, :except => [:index] do
    member do
      get :activate
    end
  end

  resources :sessions, :only => [:create]

  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout

  resources :password_resets, :only => [:create, :edit, :update, :new]
end
