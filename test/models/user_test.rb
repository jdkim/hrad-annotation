require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "initial_annotator returns the system user" do
    user = User.initial_annotator
    assert_equal "initial_annotator", user.google_uid
    assert_equal "initial@system", user.email
  end

  test "initial_annotator? returns true for initial annotator" do
    assert users(:initial).initial_annotator?
  end

  test "initial_annotator? returns false for regular user" do
    assert_not users(:annotator).initial_annotator?
  end

  test "find_or_create_from_omniauth creates new user" do
    auth = OmniAuth::AuthHash.new(
      uid: "new_uid_123",
      info: { email: "new@example.com", name: "New User" }
    )
    user = User.find_or_create_from_omniauth(auth)
    assert_equal "new_uid_123", user.google_uid
    assert_equal "new@example.com", user.email
  end

  test "find_or_create_from_omniauth finds existing user" do
    auth = OmniAuth::AuthHash.new(
      uid: users(:annotator).google_uid,
      info: { email: users(:annotator).email, name: users(:annotator).name }
    )
    assert_no_difference "User.count" do
      User.find_or_create_from_omniauth(auth)
    end
  end
end
