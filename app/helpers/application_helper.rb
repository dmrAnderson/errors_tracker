# frozen_string_literal: true

module ApplicationHelper
  def human_date(date)
    date.to_fs(:short)
  end
end
