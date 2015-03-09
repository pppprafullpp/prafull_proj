require 'api'
Rails.application.routes.draw do
  mount ServiceDeal::API => "/"

  devise_for :app_users, skip: [:sessions, :passwords, :registrations]

  namespace :api do
    namespace :v1 do
      devise_scope :app_user do
        post 'sessions' => 'sessions#create', :as => 'login'
      end
      resources :service_preferences do
        post 'service_preferences' => 'service_preferences#create'
        put  'service_preferences' => 'service_preferences#update'
      end  
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

  resources :deals
  resources :service_categories
  resources :app_users
  resources :service_preferences
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
