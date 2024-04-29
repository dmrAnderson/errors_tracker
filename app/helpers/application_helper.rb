# frozen_string_literal: true

module ApplicationHelper
  def current_organization
    @current_organization ||= Organization.find_or_create_by!(name: 'COAX')
  end

  def human_date(date)
    date.to_fs(:short)
  end
end
