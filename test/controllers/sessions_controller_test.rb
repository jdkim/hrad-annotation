require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login copies initial annotations for new user" do
    # annotator_two has no SCEs yet
    user = users(:annotator_two)

    # Initial user has SCEs for case one and case two
    initial_sces = StructuredCausalExplanation.where(user: users(:initial)).count
    assert initial_sces > 0

    assert_difference "StructuredCausalExplanation.count", initial_sces do
      sign_in user
    end

    # Verify copies exist for each case with initial annotations
    users(:initial).structured_causal_explanations.each do |sce|
      copied = user.structured_causal_explanations.find_by(medical_case: sce.medical_case)
      assert copied, "Expected copy for case #{sce.medical_case.case_id}"
      assert_equal sce.finding, copied.finding
      assert_equal sce.impression, copied.impression
      assert_equal sce.certainty, copied.certainty
    end
  end

  test "login does not duplicate annotations on re-login" do
    user = users(:annotator)
    # First login copies any missing initial annotations
    sign_in user

    # Second login should not create duplicates
    assert_no_difference "StructuredCausalExplanation.count" do
      sign_in user
    end
  end

  test "login does not copy for initial annotator" do
    assert_no_difference "StructuredCausalExplanation.count" do
      sign_in users(:initial)
    end
  end

  test "logout clears session" do
    sign_in users(:annotator)
    delete logout_path
    assert_redirected_to login_path

    get cases_path
    assert_redirected_to login_path
  end
end
