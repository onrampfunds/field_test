class UsersController < ActionController::Base
  def index
    field_test(:button_color)
    field_test_converted(:button_color)
    @experiments = field_test_experiments
  end

  def exclude
    field_test(:button_color, exclude: params[:exclude])
    head :ok
  end

  def upgrade_memberships_when_duplicate
    field_test_upgrade_memberships participant: [current_user, "visitor_token"]
    head :ok
  end

  private

  def current_user
    @current_user ||= User.last
  end
end
