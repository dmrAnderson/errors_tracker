# frozen_string_literal: true

class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  belongs_to :organization
end
