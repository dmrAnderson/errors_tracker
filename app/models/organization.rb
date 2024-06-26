# frozen_string_literal: true

class Organization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  validates :name, presence: true, uniqueness: true

  field :origin, type: String

  field :origin_confirmed_at, type: Time
  field :public_secret, type: String

  field :sent_last_webhook_at, type: Time

  with_options dependent: :delete_all do
    has_many :projects
    has_many :outbound_webhook
  end
end
