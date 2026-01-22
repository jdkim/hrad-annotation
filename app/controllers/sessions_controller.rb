class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create, :failure ]

  def new
    # Login page
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)

    session[:user_id] = user.id
    redirect_to root_path, notice: "Successfully signed in with Google!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Successfully signed out."
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end
end
