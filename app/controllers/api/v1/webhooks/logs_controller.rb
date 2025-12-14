# frozen_string_literal: true

module Api
  module V1
    module Webhooks
      class LogsController < BaseController
        include ActionController::HttpAuthentication::Token::ControllerMethods

        rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

        before_action :burst_control
        before_action :sustained_control
        before_action :authenticate_integration

        def create
          super do |record|
            LogsJob.perform_now(
              record.id.to_s,
              integration.id.to_s
            )
          end
        end

        private

        attr_reader :integration

        def authenticate_integration
          @integration = authenticate_with_http_token do |token, _|
            Integration.find_by!(public_secret: token)
          end

          return head :not_found if integration.nil?

          if Rails.env.production?
            return head :unauthorized if integration.origin != request.referer
          end

          head :forbidden if integration.confirmed_at.nil?
        end

        def burst_control
          rate_limiting(limit: 3, window: 6.seconds)
        end

        def sustained_control
          rate_limiting(limit: 100, window: 1.hour)
        end

        def rate_limiting(limit:, window:)
          cache_key = ["rate-limit", controller_path, action_name, request.remote_ip].compact.join(":")
          count = cache_store.increment(cache_key, 1, expires_in: window)
          remaining = [limit - count, 0].max
          reset_time = (cache_store.send(:read_entry, cache_key).expires_at || Time.now + window).to_i

          response.set_header('X-RateLimit-Limit', limit)
          response.set_header('X-RateLimit-Remaining', remaining)
          response.set_header('X-RateLimit-Reset', reset_time)

          if count && count > limit
            head :too_many_requests
          end
        end
      end
    end
  end
end
