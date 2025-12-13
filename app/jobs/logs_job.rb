# frozen_string_literal: true

class LogsJob < ApplicationJob
  queue_as :default

  discard_on Mongoid::Errors::DocumentNotFound

  def perform(inbound_webhook_id, integration_id)
    inbound_webhook = InboundWebhook.find(inbound_webhook_id)
    integration = Integration.find(integration_id)
    project = integration.project
    organization = project.organization

    webhook_payload ||= JSON.parse(inbound_webhook.body)

    log = Log.create!(body: webhook_payload, integration:, project:, organization:)

    inbound_webhook.update!(status: InboundWebhook::PROCESSED)

    OutboundWebhookJob.perform_now(organization.id.to_s, log.attributes, 'logs', 'create')
  end

  private

  def webhook_payload(body)
    @webhook_payload ||= JSON.parse(body, symbolize_names: true)
  end
end
