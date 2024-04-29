# frozen_string_literal: true

class InboundWebhook
  include Mongoid::Document
  include Mongoid::Timestamps

  PENDING = 10
  PROCESSED = 20
  ERROR = 30
  STATUSES = [PENDING, PROCESSED, ERROR].freeze

  field :status, type: String, default: PENDING

  field :body, type: String
end
