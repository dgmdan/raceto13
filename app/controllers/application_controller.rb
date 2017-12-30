class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true
  before_action :configure_permitted_parameters, if: :devise_controller?

  def home
  end

  def rules
  end

  def console
  end

  def test_email
    ActionMailer::Base.mail(from: 'Race To 13 <bot@raceto13.com>', to: 'danmadere@gmail.com', subject: 'Test from pool' , body: 'we get signal').deliver_later
    redirect_to root_path
  end

  def authenticate_admin!
    redirect_to new_user_session_path unless current_user && current_user.admin?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, { notification_type_ids: [] }]) # { |u| u.permit(, ) }
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :password_confirmation, :current_password, { notification_type_ids: [] }])  # { |u| u.permit({ notification_type_ids: [] }, ) }
  end
end
