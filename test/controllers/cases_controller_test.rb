require "test_helper"

class CasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:annotator)
    follow_redirect!
  end

  test "index returns success" do
    get cases_path
    assert_response :success
  end

  test "index orders cases numerically" do
    get cases_path
    assert_response :success
    assert_match /1/, response.body
    assert_match /2/, response.body
  end

  test "show returns success" do
    get case_path("1")
    assert_response :success
  end

  test "show displays only current user SCEs" do
    get case_path("1")
    assert_response :success
    # annotator has their own SCE for case one (from fixture + copied initial)
    assert_select "form" # SCE form is present
  end

  test "show displays toggle_done button" do
    get case_path("1")
    assert_select "form[action=?]", toggle_done_case_path("1")
  end

  test "toggle_done marks case as done" do
    patch toggle_done_case_path("1")
    assert_redirected_to case_path("1")

    status = AnnotationStatus.find_by(user: users(:annotator), medical_case: medical_cases(:one))
    assert status.done
  end

  test "toggle_done toggles back to not done" do
    AnnotationStatus.create!(user: users(:annotator), medical_case: medical_cases(:two), done: true)

    patch toggle_done_case_path("2")
    assert_redirected_to case_path("2")

    status = AnnotationStatus.find_by(user: users(:annotator), medical_case: medical_cases(:two))
    assert_not status.done
  end

  test "index shows done count" do
    AnnotationStatus.create!(user: users(:annotator), medical_case: medical_cases(:two), done: true)

    get cases_path
    assert_response :success
    assert_match /1 \/ 2 done/, response.body
  end

  test "unauthenticated user is redirected to login" do
    delete logout_path
    get cases_path
    assert_redirected_to login_path
  end
end
