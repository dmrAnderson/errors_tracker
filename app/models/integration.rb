# frozen_string_literal: true

class Integration
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  validates :name, presence: true, uniqueness: { scope: :project_id }

  field :origin, type: String
  validates :origin, presence: true

  field :confirmed_at, type: Time

  field :public_secret, type: String

  belongs_to :organization
  belongs_to :project

  has_many :logs, dependent: :delete_all
end
