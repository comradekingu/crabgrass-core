require 'test_helper'

class User::UnknownTest < ActiveSupport::TestCase
  def setup
    @user = User::Unknown.new
  end

  # User.may? checks for access through participations.
  # If the page is public should be checked separately
  def test_should_not_be_able_to_view_public_page
    assert !@user.may?(:view, Page.new(public: true))
  end

  def test_method_missing_raises_permission_denied
    assert_raise(PermissionDenied) do
      @user.an_unimplemented_method
    end
  end
end
