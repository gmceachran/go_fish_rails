module SignUpHelper
  def sign_up(email, password)
    visit new_user_path
    fill_in "user_email_address", with: email
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password
    click_on "Sign up"
  end

  def log_in(user)
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_on "Sign in"
  end
end
