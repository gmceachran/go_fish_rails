class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
    render layout: "application_no_sidebar"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to root_url
    else
      redirect_to new_user_path, alert: "Invalid entries."
      # render :new
    end
  end

  def show
    @email_address = current_user.email_address
    @state = "state"
    @country = "country"
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
