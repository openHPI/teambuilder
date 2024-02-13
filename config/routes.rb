Rails.application.routes.draw do

  # LTI communication
  root 'application#root'
  post '/' => 'lti#launch'
  get 'return_via_lti' => 'lti#back'

  # Auth routes
  get 'login' => 'auth#login_form'
  get 'logout' => 'auth#logout'
  post 'login' => 'auth#login'

  # Cleaned routes
  resources :courses, except: [:edit] do
    member do
      post 'copy' => 'courses#copy'
      get 'teams'
      post 'teams' => 'courses#build_teams'
      post 'teams/action' => 'courses#team_action'
    end

    resource :enrollments, only: [:new, :create, :destroy]
  end

end
