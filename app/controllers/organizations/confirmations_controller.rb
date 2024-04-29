# frozen_string_literal: true

module Organizations
  class ConfirmationsController < ApplicationController
    before_action :set_organization

    def create
      parts_of_url = URI.split(@organization.origin)

      begin
        url = URI::Generic.build(parts_of_url).to_s.freeze
      rescue ArgumentError, InvalidComponentError => e
        warn(e.message, e.class, uplevel: 1)

        flash[:notice] = e.message

        redirect_back(fallback_location: @organization)
      else
        uri = URI(url)
        Net::HTTP.start(uri.host) do |http|
          http.read_timeout = 5

          request = Net::HTTP::Get.new(uri)
          request.content_type = 'application/json'
          request['Accept'] = 'application/json'
          request['User-Agent'] = 'rails_webhook_system/1.0'
          code = http.request(request).code.to_i

          if code == 200
            @organization.update!(origin_confirmed_at: Time.current, public_secret: SecureRandom.base58(24))

            flash[:notice] = 'Organization was successfully confirmed.'
          end

          redirect_back(fallback_location: @organization)
        end
      end
    end

    private

    def set_organization
      @organization = Organization.find(params.require(:organization_id))
    end
  end
end
