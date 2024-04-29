# frozen_string_literal: true

module Organizations
  class LogsController < ApplicationController
    def index
      @logs = Log.where(organization:).desc(:created_at)
    end

    private

    def organization
      @organization ||= Organization.find(params.require(:organization_id))
    end
  end
end
