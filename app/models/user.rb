class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :custom_domains, dependent: :destroy

  has_one_attached :avatar

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, length: { maximum: 30 }, allow_blank: true

  def display_name
    username.presence || email_address.split("@").first
  end
end
