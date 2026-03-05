require "test_helper"

class ScesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:annotator)
    sign_in @user
    follow_redirect!
    @case = medical_cases(:one)
  end

  test "create adds a new SCE" do
    assert_difference "StructuredCausalExplanation.count", 1 do
      post case_sces_path(@case.case_id), params: {
        structured_causal_explanation: {
          finding: "new finding",
          impression: "new impression",
          certainty: true
        }
      }
    end
    assert_redirected_to case_path(@case.case_id)

    sce = StructuredCausalExplanation.last
    assert_equal @user, sce.user
    assert_equal "new finding", sce.finding
  end

  test "create with invalid params redirects with alert" do
    assert_no_difference "StructuredCausalExplanation.count" do
      post case_sces_path(@case.case_id), params: {
        structured_causal_explanation: {
          finding: "",
          impression: "",
          certainty: false
        }
      }
    end
    assert_redirected_to case_path(@case.case_id)
    assert flash[:alert].present?
  end

  test "edit renders form" do
    sce = structured_causal_explanations(:annotator_for_case_one)
    get edit_case_sce_path(@case.case_id, sce)
    assert_response :success
  end

  test "update modifies the SCE" do
    sce = structured_causal_explanations(:annotator_for_case_one)
    patch case_sce_path(@case.case_id, sce), params: {
      structured_causal_explanation: {
        finding: "updated finding",
        impression: "updated impression",
        certainty: false
      }
    }
    assert_redirected_to case_path(@case.case_id)
    sce.reload
    assert_equal "updated finding", sce.finding
    assert_equal false, sce.certainty
  end

  test "destroy removes the SCE" do
    sce = structured_causal_explanations(:annotator_for_case_one)
    assert_difference "StructuredCausalExplanation.count", -1 do
      delete case_sce_path(@case.case_id, sce)
    end
    assert_redirected_to case_path(@case.case_id)
  end

  test "cannot edit another user's SCE" do
    sce = structured_causal_explanations(:initial_for_case_one)
    get edit_case_sce_path(@case.case_id, sce)
    assert_redirected_to case_path(@case.case_id)
    assert_equal "You can only modify your own SCEs.", flash[:alert]
  end

  test "cannot update another user's SCE" do
    sce = structured_causal_explanations(:initial_for_case_one)
    patch case_sce_path(@case.case_id, sce), params: {
      structured_causal_explanation: { finding: "hacked" }
    }
    assert_redirected_to case_path(@case.case_id)
    sce.reload
    assert_equal "finding1", sce.finding
  end

  test "cannot destroy another user's SCE" do
    sce = structured_causal_explanations(:initial_for_case_one)
    assert_no_difference "StructuredCausalExplanation.count" do
      delete case_sce_path(@case.case_id, sce)
    end
    assert_redirected_to case_path(@case.case_id)
  end
end
