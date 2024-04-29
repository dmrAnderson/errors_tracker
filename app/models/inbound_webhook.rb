# frozen_string_literal: true

class InboundWebhook
  include Mongoid::Document
  include Mongoid::Timestamps

  PENDING = 'pending'
  PROCESSED = 'processed'
  ERROR = 'error'
  STATUSES = [PENDING, PROCESSED, ERROR].freeze

  field :status, type: String, default: PENDING

  field :body, type: String
end
