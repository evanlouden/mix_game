class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def require_admin!
    authenticate_user!
    head :forbidden unless current_user&.admin?
  end
end
