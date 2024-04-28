# frozen_string_literal: true

class Organization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  validates :name, presence: true, uniqueness: true

  has_many :projects, dependent: :delete_all
end
