# frozen_string_literal: true

module ApplicationHelper
  NAME = 'COAX'

  def current_organization
    @current_organization ||= Organization.find_or_create_by!(name: NAME)
  end

  def human_date(date)
    date.to_fs(:short)
  end
end
