class MedicalCase < ApplicationRecord
  has_many :structured_causal_explanations, dependent: :destroy
  has_many :annotation_statuses, dependent: :destroy

  validates :case_id, presence: true, uniqueness: true

  def to_param
    case_id
  end
end
