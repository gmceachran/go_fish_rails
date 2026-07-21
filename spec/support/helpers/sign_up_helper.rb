module SignUpHelper
  def sign_up(email, password)
    visit new_user_path
    fill_in "user_email_address", with: email
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password
    click_on "Create User"
  end

  def log_in(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: user.password
    click_on "Log in"
  end

  def log_out
    User.all.each do |user|
      Current.session&.destroy!
      cookies.delete(:session_id)
    end
  end

  def create_and_log_in
    user = create :user
    # sleep 0.3
    log_in user
    user
  end
end
