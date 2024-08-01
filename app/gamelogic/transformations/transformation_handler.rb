# frozen_string_literal: true

module Transformations
  # makes it easier to use subclasses of class Transformation
  module TransformationHandler
    def handle(name, *args)
      dd = data.deep_duplicate
      dd.uidata = UiData.fresh
      transform_result(name, dd, args) => { handled:, success:, new_data:, errors: }
      @handled = handled
      @success = success

      self.data = new_data if success && handled
      data.move_status = { ok: @success, error: errors.first } if handled
      after_transform(success) if handled
      @handled
    end

    def handled?
      @handled
    end

    def transform_result(name, data, args)
      @result = nil

      transform(name, data, args) do |given_name, given_data, given_args|
        t = transformation_list[given_name]
        c = ui.nil? ? ConsoleUi.new(:none) : ui # if no console, set to dummy
        @result = t.process(given_data.deep_duplicate, given_args, c)
      end

      @result
    end

    def transform(name, data, args)
      yield(name, data, args)
    end

    def success?
      @success
    end

    # here you can use updated data
    def after_transform(success)
      # do nothing
    end
  end
end
