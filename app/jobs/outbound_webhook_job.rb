# frozen_string_literal: true

class OutboundWebhookJob < ApplicationJob
  GAP_TIME = 5.seconds

  queue_as :default

  def perform(organization_id, attributes, controller_name, action_name)
    organization = Organization.find(organization_id)
    return unless organization.origin_confirmed_at?

    body = attributes.transform_values(&:to_s)
    kind = [controller_name, action_name].map { |item| item.to_s.downcase }.join('.')

    subscription = organization.webhook_events.fetch(controller_name.to_s).fetch(action_name.to_s, false)
    return unless subscription

    outbound_webhook = OutboundWebhook.create!(organization:, kind:, body:)

    if organization.sent_last_webhook_at && (organization.sent_last_webhook_at > Time.current - GAP_TIME)
      return outbound_webhook.update!(status: OutboundWebhook::OMITTED)
    end

    organization.update!(sent_last_webhook_at: Time.current)

    outbound_webhook.send_request!
  end
end
