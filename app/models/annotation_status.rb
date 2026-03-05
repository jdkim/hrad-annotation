class AnnotationStatus < ApplicationRecord
  belongs_to :user
  belongs_to :medical_case

  validates :user_id, uniqueness: { scope: :medical_case_id }
end
