Rails.application.routes.draw do
  # namespace :identity do
  #   resource :email,              only: [:edit, :update]
  #   resource :email_verification, only: [:show, :create]
  #   resource :password_reset,     only: [:new, :edit, :create, :update]
  # end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
   
  # api endpoints
  namespace :api do
    namespace :v1 do
      # --- Auth entry points (all public / unauthenticated) ---
      resource :registration, only: [:create]
      resource :session, only: [:create]
      resource :token_refresh, only: [:create]
      resource :account_link, only: [:create]
      post 'oauth/google', to: 'oauth_sessions#create'
      resource :password_reset, only: %i[create update]
      resource :email_verification, only: [:create] do
        post :resend, on: :collection
      end

      # --- Authenticated account-level (not family-scoped) ---
      resource :profile, only: %i[show update], controller: 'profile' do
        patch :timezone
      end
      resources :timezones, only: [:index]
      resources :refresh_tokens, only: %i[index destroy] do
        collection { delete :destroy_all }
      end
      resource :invitation_redemption, only: [:create]
      resources :account_requests, only: %i[index create]
      resource :password_change, only: [:update]

      # --- Families and everything scoped inside one ---
      resources :families, only: %i[index show create update] do
        member { post :switch }

        resources :memberships, only: %i[index destroy] do
          collection do
            post :leave
            get :former
          end
          member do
            post :grant_admin
            post :revoke_admin
            post :transfer_ownership
            post :age_up
            post :reactivate
            patch :set_color
          end
        end

        resources :dependents, only: %i[create destroy] do
          member { post :claim }
        end
        resources :guardianships, only: %i[create destroy]
        resources :invitations, only: %i[index create destroy]

        resources :events do
          collection { post :check_overlap }
          member do
            patch :occurrence
            delete :occurrence
          end
          resources :participants, only: %i[create destroy], controller: 'event_participants'
          resources :reminders, only: %i[index create destroy], controller: 'event_reminders'
        end
        resources :agenda_subscriptions, only: %i[index create update destroy]
      end

      resource :notification_preferences, only: %i[show update], controller: 'notification_preferences'
      resource :ical_feed_token, only: %i[show create], controller: 'ical_feed_tokens'

      # Unauthenticated - hit directly by external calendar apps, gated by
      # the opaque token in the URL itself rather than a bearer header.
      get 'ical/:token/feed.ics', to: 'ical_feeds#show', as: :ical_feed
    end
  end
end
