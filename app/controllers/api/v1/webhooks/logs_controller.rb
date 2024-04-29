# frozen_string_literal: true

module Api
  module V1
    module Webhooks
      class LogsController < BaseController
        include ActionController::HttpAuthentication::Token::ControllerMethods

        rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

        before_action do
          authenticate_token || not_found
        end

        def create
          super do |record|
            LogsJob.perform_now(
              record.id.to_s,
              integration.id.to_s
            )
          end
        end

        private

        def integration
          authenticate_with_http_token do |token, _options|
            Integration.where.not(confirmed_at: nil).find_by(public_secret: token)
          end
        end
        alias authenticate_token integration

        def not_found
          render(json: { error: 'Integration not found' }, status: :not_found)
        end
      end
    end
  end
end
