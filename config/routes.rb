Sportzserver::Application.routes.draw do

  devise_for :users, controllers: {registrations: "users/registrations"}

  resources :users, only: [:edit, :update, :show, :index] do
    member do
      get   :site, :disable, :enable
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tokens, only: [:create, :destroy]
    end
  end  
   
  resources :sports do
    resources :contacts
    resources :sponsors

    resources :events do
      collection do
        get :newteam
      end
    end

    resources :blogs do
      collection do
        get :updateforteams
      end
      
      member do
        get :comment
      end
    end

    resources :teams,   only: [:new, :create, :edit, :update, :destroy, :index, :show] do
      resources :gameschedules, only: [:show, :new, :create, :edit, :update, :index, :destroy] do
        resources :gamelogs, only: [:create, :destroy, :show, :update]
      end
    end
    
    resources :newsfeeds do
      collection do
        get :updateteams
      end
    end

    resources :athletes do

      resources :alerts, only: [:index, :destroy] do
        collection do
          get :clearall
        end
      end
 
      resources :football_stats, only: [:create] do
        collection do
          get :passing, :rushing, :receiving, :defense, :specialteams, :showdata
        end

        member do
          get :newstat, :getrushing, :getpassing, :getreceiving, :getdefense, :getkicker, :getreturner
        end

        resources :football_passings, only: [:new, :create, :show, :edit, :update, :destroy] do
          member do
            get :add
          end 

          collection do
            get :addattempt
          end
        end

        resources :football_rushings, only: [:new, :create, :show, :edit, :update, :destroy] do
          member do
            get :add
          end 

          collection do
            get :addcarry
          end
        end

        resources :football_receivings, only: [:new, :create, :show, :edit, :update, :destroy]

        resources :football_defenses, only: [:new, :create, :show, :edit, :update, :destroy] do
          member do
            get :add
          end 

          collection do
            get :adddefense
          end
        end          

        resources :football_kickers, only: [:create, :show, :update, :destroy] do
          member do
            get :addplacekicker, :addpunter, :addkickoff
          end

          collection do
            get :newkicker, :newpunter, :newkickoff, :editkicker, :editpunter, :editkickoff, :placekicker, :punter, :kickoff
          end
        end

        resources :football_returners, only: [:create, :show, :update, :destroy] do
          member do
            get :addko, :addpunt
          end

          collection do
            get :newkoreturn, :newpuntreturn, :editkoreturn, :editpuntreturn, :koreturn, :puntreturn
          end
        end

        resources :basketball_stats

      end
 
      member do
        get :follow, :unfollow, :stats
      end
    end

    resources :coaches do
      member do
        get   :copy
      end
    end
    
    resources :photos, only: [:edit, :create, :update, :destroy, :index, :show] do
      member do
        get :newteam, :newathlete, :newschedule, :errors, :approval
        get :slideshow
        get :untagteam
      end

      collection do
        post :untagathlete
        get :updategameschedule, :clear_error
      end
    end
    
    resources :videoclips, only: [:edit, :create, :update, :destroy, :index, :show] do
      member do
        get :newteam, :newathlete, :newschedule, :untagteam
      end

      collection do
        post :untagathlete
        get :updategameschedule
      end
    end

    collection do
      get :feed, :mobileinfo, :allnews, :pricing, :admin_info
    end

    member do
      get :sport_user_alerts
      get  :updateabout
      get  :updatecontact
      post :uploadpage
      post :uploadcontact
    end

  end
  
#  resources :sites do
#    resources :contacts

#    member do
#      get  :updateabout
#      get  :updatecontact
#      post :uploadpage
#      post :uploadcontact
#    end
    
#    collection do
#      get  :male, :female, :mobileinfo, :allnews, :pricing
#    end

#  end
  
  root to: 'sports#home'

  match '/home',    to: 'sports#home'
  match '/help',    to: 'sports#help'
  match '/contacts', to: 'sports#contact'
  match '/about',   to: 'sports#about'
  match '/info',    to: 'sports#info'
  match '/admininfo', to: 'sports#admin_info'
  match '/pricing',  to: 'sports#pricing'
  match '/mobileinfo',  to: 'sports#mobileinfo'
  match '/user/root',  to: 'sports#show'

  match '/newkicker', to: 'football_kickers#newkicker'
  match '/newpunter', to: 'football_kickers#newpunter'
  match '/newkoreturn', to: 'football_returners#newkoreturn'
  match '/newpuntreturn', to: 'football_returns#newpuntreturn'
   
  authenticate :user, lambda {|u| u.admin == true} do
    mount Resque::Server, :at => "/resque"
  end

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404'
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
