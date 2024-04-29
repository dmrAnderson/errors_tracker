# frozen_string_literal: true

class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: Hash
  validates :body, presence: true

  belongs_to :organization
  belongs_to :project
  belongs_to :integration
end
