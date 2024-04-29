# frozen_string_literal: true

class OutboundWebhookJob < ApplicationJob
  queue_as :default

  def perform(organization_id, attributes, controller_name, action_name)
    organization = Organization.where.not(origin_confirmed_at: nil).find(organization_id)
    body = attributes.transform_values(&:to_s)
    kind = [controller_name, action_name].map { |item| item.to_s.downcase }.join('.')

    outbound_webhook = OutboundWebhook.create!(organization:, kind:, body:)

    outbound_webhook.send_request!
  end
end
