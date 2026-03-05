require "test_helper"

class AnnotationStatusTest < ActiveSupport::TestCase
  test "user and medical_case combination must be unique" do
    duplicate = AnnotationStatus.new(
      user: users(:annotator),
      medical_case: medical_cases(:one),
      done: true
    )
    assert_not duplicate.valid?
  end

  test "defaults to not done" do
    status = AnnotationStatus.create!(user: users(:annotator_two), medical_case: medical_cases(:one))
    assert_equal false, status.done
  end
end
