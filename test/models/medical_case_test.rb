require "test_helper"

class MedicalCaseTest < ActiveSupport::TestCase
  test "case_id must be unique" do
    duplicate = MedicalCase.new(case_id: medical_cases(:one).case_id)
    assert_not duplicate.valid?
  end

  test "case_id must be present" do
    blank = MedicalCase.new(case_id: nil)
    assert_not blank.valid?
  end

  test "to_param returns case_id" do
    assert_equal "1", medical_cases(:one).to_param
  end

  test "destroying case destroys associated SCEs" do
    medical_case = medical_cases(:one)
    sce_count = medical_case.structured_causal_explanations.count
    assert sce_count > 0

    assert_difference "StructuredCausalExplanation.count", -sce_count do
      medical_case.destroy
    end
  end
end
