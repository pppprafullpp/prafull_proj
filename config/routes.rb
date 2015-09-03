require 'api'
Rails.application.routes.draw do
  #mount ServiceDeal::API => "/"

  devise_for :app_users, skip: [:sessions, :passwords, :registrations]

  namespace :api do
    namespace :v1 do
      devise_scope :app_user do
        post 'sessions' => 'sessions#create', :as => 'login'
      end
      #resources :service_preferences do
        match 'service_preferences' => 'service_preferences#create', :via => :post
      #end 
      #resources :notifications do 
        match 'notifications' => 'notifications#create', :via => :post
        match 'get_notification' => 'notifications#fetch_notification', :via => :get
      #end 
      #resources :app_users do
        match 'app_users' => 'app_users#create', :via => :post
        match 'update_user' => 'app_users#update_app_user', :via => :post

        match 'service_providers' => 'service_providers#get_service_providers', :via => :get

        match 'get_preferences' => 'service_preferences#fetch_service_preferences', :via => :get
      #end 
      #resources :comments do
      #  post 'comments' => 'comments#create'
      #  get 'comments'  => 'comments#index'
      #end
      #resources :ratings do
      #  post 'ratings' => 'ratings#create'
      #  get 'ratings'  => 'ratings#index'
      #end
      #resources :comment_ratings do
      #end  
      resources :dashboards do
        post 'dashboards' => 'dashboards#index'
      end 
      resources :deals do
        get 'deals' => 'deals#index'
      end  
      match 'app_user' => 'app_users#get_app_user', :via => :get
      match 'service_preferences' => 'service_preferences#get_service_preferences', :via => :get
      match 'forget_password' => 'app_users#recover_password', :via => :post
      match 'comment_ratings' => 'comment_ratings#create', :via => :post
      match 'comment_ratings' => 'comment_ratings#index', :via => :get
      #match 'ratings' => 'comment_ratings#create', :via => :post
      #match 'ratings' => 'comment_ratings#index', :via => :get
    end
  end
  root to: "home#index"

  devise_for :users
  resources :users do
    member do
      get :edit_password
      get :unlock
      put :update_password
    end
    collection do
      get :reset_password
      post :set_reset_password
    end
  end  

  get 'deals/get_service_providers'=>'deals#get_service_providers'
  
  
  resources :deals
  resources :service_categories
  resources :app_users
  resources :service_preferences
  resources :notifications
  resources :service_providers
  resources :advertisements
  #resources :comments
  #resources :ratings
  resources :push_notifications
  resources :comment_ratings
    #:path_names => { sign_in: 'login', sign_out: 'logout' },
    #:controllers => { :sessions => "sessions", 
    #                  :registrations => 'registrations'
    #                }
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
