require "test_helper"

class StructuredCausalExplanationTest < ActiveSupport::TestCase
  test "finding must be present" do
    sce = StructuredCausalExplanation.new(
      medical_case: medical_cases(:one),
      user: users(:annotator),
      finding: nil,
      impression: "some impression"
    )
    assert_not sce.valid?
    assert_includes sce.errors[:finding], "can't be blank"
  end

  test "impression must be present" do
    sce = StructuredCausalExplanation.new(
      medical_case: medical_cases(:one),
      user: users(:annotator),
      finding: "some finding",
      impression: nil
    )
    assert_not sce.valid?
    assert_includes sce.errors[:impression], "can't be blank"
  end

  test "valid SCE saves successfully" do
    sce = StructuredCausalExplanation.new(
      medical_case: medical_cases(:one),
      user: users(:annotator_two),
      finding: "new finding",
      impression: "new impression",
      certainty: true
    )
    assert sce.valid?
    assert sce.save
  end

  test "belongs to medical_case" do
    sce = structured_causal_explanations(:initial_for_case_one)
    assert_equal medical_cases(:one), sce.medical_case
  end

  test "belongs to user" do
    sce = structured_causal_explanations(:initial_for_case_one)
    assert_equal users(:initial), sce.user
  end
end
