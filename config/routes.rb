Sportzserver::Application.routes.draw do

  devise_for :users, controllers: {registrations: "users/registrations"}

  resources :users, only: [:edit, :update, :show] do
    member do
      get   :site
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tokens, only: [:create, :destroy]
    end
  end  
   
  resources :sports do
    resources :teams,   only: [:new, :create, :edit, :update, :destroy] do
      resources :gameschedules
    end
    
    resources :newsfeeds 
  
    resources :athletes do
      member do
        get :follow, :unfollow
      end
    end

    resources :coaches do
      member do
        get   :copy
      end
    end
    
    resources :photos, only: [:edit, :create, :update, :destroy, :index, :show] do
      member do
        get :newteam
        get :newathlete
        get :slideshow
        get :untagteam
      end

      collection do
        post  :untagathlete
      end
    end

    collection do
      get :feed
    end
  end
  
  resources :sites do
    resources :contacts

    member do
      get  :updateabout
      get  :updatecontact
      post :uploadpage
      post :uploadcontact
    end
    
    collection do
      get  :male, :female, :mobileinfo, :allnews
    end
  end
  
  root to: 'sites#home'

  match '/home',    to: 'sites#home'
  match '/help',    to: 'sites#help'
  match '/contacts', to: 'sites#contact'
  match '/about',   to: 'sites#about'
  match '/info',    to: 'sites#info'
  match '/mobileinfo',  to: 'sites#mobileinfo'
  match '/user/root',  to: 'sites#show'
   
  authenticate :user do
    mount Resque::Server, :at => "/resque"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
