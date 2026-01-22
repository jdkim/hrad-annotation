Rails.application.routes.draw do
  # Authentication routes
  get "login", to: "sessions#new", as: :login
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "logout", to: "sessions#destroy", as: :logout

  # Cases and SCE routes
  resources :cases, only: [ :index, :show ], param: :case_id do
    resources :sces, only: [ :create, :edit, :update, :destroy ]
  end

  # Image serving route
  get "cases/:case_id/images/:filename", to: "cases#image", as: :case_image, constraints: { filename: /[^\/]+/ }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "cases#index"
end
