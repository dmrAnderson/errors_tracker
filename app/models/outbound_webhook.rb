# frozen_string_literal: true

class OutboundWebhook
  include Mongoid::Document
  include Mongoid::Timestamps

  PENDING = 'pending'
  PROCESSED = 'processed'
  OMITTED = 'omitted'
  ERROR = 'error'

  field :status, type: String, default: PENDING

  field :last_sent_at, type: Time

  field :kind, type: String
  validates :kind, presence: true

  field :last_response_code, type: Integer

  field :body, type: Hash
  validates :body, presence: true

  belongs_to :organization

  def send_request!
    return if organization.origin.blank?

    parts_of_url = URI.split(organization.origin)

    begin
      url = URI::Generic.build(parts_of_url).to_s.freeze
    rescue ArgumentError, InvalidComponentError => e
      warn(e.message, e.class, uplevel: 1)
      update!(status: ERROR, last_sent_at: Time.current)
    else
      uri = URI(url)
      Net::HTTP.start(uri.host) do |http|
        http.read_timeout = 5

        request = Net::HTTP::Get.new(uri)
        request.content_type = 'application/json'
        request['Accept'] = 'application/json'
        request['User-Agent'] = 'rails_webhook_system/1.0'
        request['Authorization'] = "Bearer #{organization.public_secret}"
        request['X-Rails-Webhook-Gap'] = OutboundWebhookJob::GAP_TIME
        time = organization.sent_last_webhook_at + OutboundWebhookJob::GAP_TIME
        request['X-Rails-Webhook-Gap-Until'] = time.iso8601

        request.body = { event: kind, body: }.to_json

        response = http.request(request)

        if response.code.to_i == 200
          update!(status: PROCESSED, last_sent_at: Time.current, last_response_code: response.code)
        else
          update!(status: ERROR, last_sent_at: Time.current, last_response_code: response.code)
        end
      end
    end
  end
end
