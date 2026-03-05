class User < ApplicationRecord
  has_many :structured_causal_explanations, dependent: :destroy
  has_many :annotation_statuses, dependent: :destroy

  validates :email, presence: true
  validates :google_uid, presence: true, uniqueness: true

  INITIAL_ANNOTATOR_UID = "initial_annotator"

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by(google_uid: auth.uid) do |user|
      user.email = auth.info.email
      user.name = auth.info.name
    end
  end

  def self.initial_annotator
    find_or_create_by(google_uid: INITIAL_ANNOTATOR_UID) do |user|
      user.email = "initial@system"
      user.name = "Initial Annotator"
    end
  end

  def initial_annotator?
    google_uid == INITIAL_ANNOTATOR_UID
  end
end
