# frozen_string_literal: true

class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  validates :name, presence: true, uniqueness: { scope: :organization_id }

  belongs_to :organization

  has_many :integrations, dependent: :delete_all
end
