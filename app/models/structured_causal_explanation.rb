class StructuredCausalExplanation < ApplicationRecord
  belongs_to :medical_case
  belongs_to :user

  validates :finding, presence: true
  validates :impression, presence: true
end
