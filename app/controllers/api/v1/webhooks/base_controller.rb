# frozen_string_literal: true

module Api
  module V1
    module Webhooks
      class BaseController < ::ActionController::API
        abstract!

        def create
          yield record if block_given?
          head :ok
        end

        private

        def record
          @record ||= InboundWebhook.create!(body: payload)
        end
        alias create_record! record

        def payload
          @payload ||= request.body.read
        end
      end
    end
  end
end
