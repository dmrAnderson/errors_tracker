# frozen_string_literal: true

module Integrations
  class ConfirmationsController < ApplicationController
    before_action :set_integration

    def create
    end

    def update
      parts_of_url = URI.split(@integration.origin)

      begin
        url = URI::Generic.build(parts_of_url).to_s.freeze
      rescue ArgumentError, InvalidComponentError => e
        warn(e.message, e.class, uplevel: 1)

        flash[:notice] = e.message

        redirect_back(
          fallback_location: organization_project_path(@integration.project.organization, @integration.project)
        )
      else
        uri = URI(url)
        Net::HTTP.start(uri.host) do |http|
          http.read_timeout = 5

          request = Net::HTTP::Get.new(uri)
          request.content_type = 'application/json'
          request['Accept'] = 'application/json'
          request['User-Agent'] = 'rails_webhook_system/1.0'

          if http.request(request).code.to_i == 200
            @integration.update!(confirmed_at: Time.now)
          end

          redirect_back(
            fallback_location: organization_project_path(@integration.project.organization, @integration.project)
          )
        end
      end
    end

    private

    def set_integration
      @integration = Integration.find(params.require(:id))
    end
  end
end
