# frozen_string_literal: true

class Organization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :projects, dependent: :destroy
end
