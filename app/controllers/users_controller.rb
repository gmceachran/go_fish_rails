class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def turbo_fetch
    @user = User.new(update_user_params)
  end

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
    end
  end

  def show
    @user = current_user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update update_user_params
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:country, :state)
  end
end
