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
      resource :profile, only: %i[show update], controller: 'profile'
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
          end
        end

        resources :dependents, only: %i[create destroy] do
          member { post :claim }
        end
        resources :guardianships, only: %i[create destroy]
        resources :invitations, only: %i[index create destroy]
      end
    end
  end
end
