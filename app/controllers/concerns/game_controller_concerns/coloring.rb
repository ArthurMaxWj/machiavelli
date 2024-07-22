# frozen_string_literal: true

module GameControllerConcerns
  # use to set colors of Info/Errors tab in control panel in frontend (see index view)
  module Coloring
    extend ActiveSupport::Concern

    def infoerror_highest_level
      # 0 is none, 2 is requirements error handled by front
      order = { who_cheated: 1, warning: 3, error: 4 }

      return order[:error] if flash[:error].present?
      return order[:warning] if flash[:warning].present?
      return order[:who_cheated] if session[:who_cheated].present?

      0
    end
  end
end
