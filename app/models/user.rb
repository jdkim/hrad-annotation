class User < ApplicationRecord
  has_many :structured_causal_explanations, dependent: :destroy

  validates :email, presence: true
  validates :google_uid, presence: true, uniqueness: true

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by(google_uid: auth.uid) do |user|
      user.email = auth.info.email
      user.name = auth.info.name
    end
  end
end
