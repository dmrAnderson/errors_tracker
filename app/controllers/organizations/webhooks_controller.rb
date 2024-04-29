# frozen_string_literal: true

module Organizations
  class WebhooksController < ApplicationController
    def index
      @outbound_webhooks = OutboundWebhook.where(organization:).desc(:created_at)
    end

    private

    def organization
      @organization ||= Organization.find(params.require(:organization_id))
    end
  end
end
