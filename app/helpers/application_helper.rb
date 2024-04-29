# frozen_string_literal: true

module ApplicationHelper
  NAME = 'COAX'
  ORIGIN = 'https://www.google.com/'

  def current_organization
    @current_organization ||= Organization.find_or_create_by!(name: NAME, origin: ORIGIN)
  end

  def human_date(date)
    date.to_fs(:short)
  end
end
