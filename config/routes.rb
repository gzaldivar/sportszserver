Sportzserver::Application.routes.draw do

  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", confirmations: "users/confirmations" }

  resources :users, only: [:edit, :update, :show, :index] do
    member do
      get :sitechange, :disable, :enable, :delete_avatar, :getuser, :cleanup
#      put   :update_user_info
      put :createavatar, :uploadavatar
    end

  end

  namespace :api do
    namespace :v1 do
      resources :tokens, only: [:create, :destroy]
    end
  end  
   
  resources :payments, only: [:index, :new, :show, :create] do
    collection do
      get :confirmsilver, :confirmgold, :confirmplatinum, :cancel, :upgrade
    end
  end
    
  resources :admins, only: [:edit, :update, :index] do
    collection do
      get   :users, :deleteuser, :sports
    end
  end

  resources :sports do
    resources :contacts

    resources :sponsors do
      member do
        put :updatephoto
      end
      
      collection do
        post :createphoto
      end
    end

    resources :events do
      collection do
        get :newteam
      end
    end

    resources :blogs do
      collection do
        get :updateforteams, :newteamblog, :updategamelogs
      end
      
      member do
        get :comment
      end
    end

    resources :teams,   only: [:new, :create, :edit, :update, :destroy, :index, :show] do
      member do
        get   :getplayers, :teamlogo
        post  :addplayers
        put   :createteamlogo, :updatelogo
      end
      
      resources :gameschedules, only: [:show, :new, :create, :edit, :update, :index, :destroy] do
        
        collection do
          get   :periods, :findsport, :findteam
          put   :defineperiods
          post  :createlogo
        end

        member do
          get   :passinggamestats, :rushinggamestats, :allfootballgamestats, :receivinggamestats, :defensegamestats, :kickergamestats, :returnergamestats,
                :footballboxscore, :footballscoreboard, :footballteamgametotals,  :footballdefensestats, :footballspecialteamstats, 
                :addfootballqb, :addfootballrb, :addfootballrec, :addfootballdef, :addfootballkicker, :addfootballpunter, :addfootballpk,
                :addfootballret, :footballform, :basketballteamscorestats, :basketballteamotherstats, :basketballform, :soccerform
          put   :updatelogo
        end

        resources :gamelogs, only: [:new, :create, :edit, :destroy, :show, :update, :index] do
          collection do
            get :gamelogs
          end
        end
      end

      resources :standings, only: [:index] do
        collection do
          get :addgamerecord, :importteamrecord
          put :savegamerecord
        end
      end
    end
    
    resources :newsfeeds do
      member do
        put   :updatephoto
      end
      collection do
        post :createphoto
        get :updateteams
      end
    end

    resources :athletes do

      resources :alerts, only: [:index, :destroy] do
        collection do
          get :clearall
        end
      end
 
      resources :football_passings, only: [:create, :update, :destroy, :index, :show]
 
      resources :football_rushings, only: [:create, :update, :destroy, :index, :show]

      resources :football_receivings, only: [:create, :update, :destroy, :index, :show]

      resources :football_defenses, only: [:create, :update, :destroy, :index, :show]

      resources :football_kickers, only: [:create, :update, :destroy, :index, :show]

      resources :football_returners, only: [:create, :update, :destroy, :index, :show]

      resources :football_place_kickers, only: [:create, :update, :destroy, :index, :show]

      resources :football_punters, only: [:create, :update, :destroy, :index, :show]

      resources :basketball_stats, only: [:create, :show, :update, :index, :destroy, :edit] do
        collection do
          get   :newstat
        end
      end

      resources :soccers
      
      member do
        get :follow, :unfollow, :stats, :playerstats
        put :updatephoto, :selectedstat
      end
      
      collection do
        post :createathletephoto
      end

    end

    resources :coaches do
      member do
        get   :copy
        put   :updatephoto
      end
      collection do
        post :createcoachphoto
      end
    end
    
    resources :photos, only: [:edit, :create, :update, :destroy, :index, :show] do
      member do
        get :errors, :approval
        put :untag_athletes, :tag_athletes
        get :slideshow
        get :untagteam
      end

      collection do
        post :untagathlete, :createmobile, :updatefeaturedphotos
        get :newteam, :newathlete, :newschedule, :updategameschedule, :clear_error, :updategamelogs, :photoshome, :featuredphoto, :showfeaturedphotos, :displayphoto, :latest,
            :updatefeaturedphotoslist, :deletefeaturedphoto
      end
    end
    
    resources :videoclips, only: [:edit, :create, :update, :destroy, :index, :show] do
      member do
        get :newteam, :newathlete, :newschedule, :untagteam
        put :untag_athletes, :tag_athletes
      end

      collection do
        post :untagathlete, :createmobile, :updatefeaturedvideos, :createclient
        get :newteam, :newathlete, :newschedule, :updategameschedule, :updategamelogs, :videoclipshome, :showfeaturedvideos, :latest, 
            :displayvideo, :featuredvideo, :updatefeaturedvideoclipslist, :deletefeaturedvideoclips
      end
    end

    collection do
      get :feed, :mobileinfo, :allnews, :pricing, :admin_info, :websiteinfo, :ipadexample_path, :approve, :eazefootball, :eazebasketball,
          :infobasketball, :webbballinfo, :iphone_basketballinfo, :about, :eazesoccer, :testcss, :faqs, :get_usstates
    end

    member do
      get :sport_user_alerts, :displaynews, :updatecontact, :selectteam, :sortplayernews, :sortgamenews, :allnews, 
          :selectfeaturedplayers, :showfeaturedplayers, :showfollowedplayers, :updateabout, :clearabout
      post :uploadpage, :uploadcontact
      put :updatelogo, :featuredplayers, :uploadabout
    end

  end
    
  root to: 'sports#home'

  match '/home',    to: 'sports#home'
  match '/help',    to: 'sports#help'
  match '/contacts', to: 'sports#contact'
  match '/about',   to: 'sports#about'
  match '/info',    to: 'sports#infofootball'
  match '/admininfo', to: 'sports#admin_info'
  match '/pricing',  to: 'sports#pricing'
  match '/mobileinfo',  to: 'sports#mobileinfo'
  match '/websiteinfo', to: 'sports#websiteinfo'
  match '/ipadexample', to: 'sports#ipadexample_info'
  match '/user/root',  to: 'sports#show'
  match '/approve', to: 'sports#approve'
  match '/eazefootball', to: 'sports#eazefootball'
  match '/eazebasketball', to: 'sports#eazebasketball'
  match '/eazesoccer', to: 'sports#eazesoccer'
  match '/infobasketball', to: 'sports#infobasketball'
  match '/iphone_basketball', to: 'sports#iphone_basketballinfo'
  match '/webbballinfo', to: 'sports#webbballinfo'
  match '/webbballinfo', to: 'sports#websiteinfo'
  match '/publisher', to: 'sports#publisher'
  match '/faqs', to: 'sports#faqs'
   
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
