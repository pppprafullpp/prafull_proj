require 'api'
Rails.application.routes.draw do
  devise_for :app_users, skip: [:sessions, :passwords, :registrations]

  namespace :api do
    namespace :v1 do
      devise_scope :app_user do
        post 'sessions' => 'sessions#create', :as => 'login'
      end
      match 'service_categories' => 'service_categories#index', :via => :get
      match 'service_preferences' => 'service_preferences#create', :via => :post
      match 'service_preferences/send_ios_notification' => 'service_preferences#send_ios_notification', :via => :get
      match 'notifications' => 'notifications#create', :via => :post
      match 'get_notification' => 'notifications#fetch_notification', :via => :get
      match 'app_users' => 'app_users#create', :via => :post
      match 'update_user' => 'app_users#update_app_user', :via => :post
      match 'service_providers' => 'service_providers#get_service_providers', :via => :get
      match 'get_preferences' => 'service_preferences#fetch_service_preferences', :via => :get
      match 'deselect_prference' => 'service_preferences#deselect_service_preference', :via => :delete
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
      match 'referral_tracking' => 'referral_infos#create', :via => :post
      match 'get_category_deals' => 'dashboards#category_deals', :via => :get
      match 'subscribed_deals' => 'subscribe_deals#subscription_info', :via => :post
      match 'orders' => 'orders#create', :via => :post
      match 'get_orders' => 'orders#get_orders', :via => :get
      match 'my_orders' => 'orders#my_orders', :via => :get
      match 'get_gifts' => 'gifts#get_gifts', :via => :get
      match 'account_referrals' => 'account_referrals#create', :via => :post
      match 'referral_code' => 'app_users#my_referral_code', :via => :get
      match 'my_earnings' => 'app_users#referrals_and_gifts', :via => :get




    end
  end

  #resources :service_categories do
  #  collection { post :import }
  #end


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


  resources :deals do
    post 'import', on: :collection
  end
  resources :service_categories do
    post 'import', on: :collection
  end
  resources :app_users
  resources :service_preferences
  resources :notifications
  resources :service_providers do
    post 'import', on: :collection
  end
  resources :advertisements
  #resources :comments
  #resources :ratings
  resources :bulk_notifications
  resources :comment_ratings
  resources :referral_infos
  resources :internet_service_preferences
  resources :cable_service_preferences
  resources :telephone_service_preferences
  resources :cellphone_service_preferences
  resources :bundle_service_preferences
  resources :subscribe_deals
  resources :trending_deals
  resources :zipcodes do
    post 'import', on: :collection
  end
  resources :orders
  resources :gifts
  resources :user_gifts



  get 'service_deals' => 'website/home#index'
  namespace :website do
    resources :home do
      collection do
        get :deals
      end
    end
    resources :app_users do
      collection do
        get :check_user_email_ajax
        get :signout
        post :signin
      end
    end
  end
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
