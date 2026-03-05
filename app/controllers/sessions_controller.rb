class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create, :failure ]

  def new
    # Login page
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_omniauth(auth)

    copy_initial_annotations(user) unless user.initial_annotator?

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

  private

  def copy_initial_annotations(user)
    initial_user = User.find_by(google_uid: User::INITIAL_ANNOTATOR_UID)
    return unless initial_user

    initial_user.structured_causal_explanations.find_each do |sce|
      next if user.structured_causal_explanations.exists?(medical_case: sce.medical_case)

      user.structured_causal_explanations.create(
        medical_case: sce.medical_case,
        finding: sce.finding,
        impression: sce.impression,
        certainty: sce.certainty
      )
    end
  end
end
