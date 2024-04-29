# frozen_string_literal: true

class LogsJob < ApplicationJob
  queue_as :default

  def perform(inbound_webhook_id, integration_id)
    inbound_webhook = InboundWebhook.find(inbound_webhook_id)
    integration = Integration.find(integration_id)
    project = integration.project
    organization = project.organization

    webhook_payload ||= JSON.parse(inbound_webhook.body)

    Log.create!(body: webhook_payload, integration:, project:, organization:)

    inbound_webhook.update!(status: InboundWebhook::PROCESSED)
  end

  private

  def webhook_payload(body)
    @webhook_payload ||= JSON.parse(body, symbolize_names: true)
  end
end
