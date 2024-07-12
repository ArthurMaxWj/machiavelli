# frozen_string_literal: true

module Transformations
  # defines basic fucntionality to transofrm some data (with not mfound and success options)
  class Transformation
    attr_reader :hdata, :errors, :console

    def initialize
      @handled = false
      @success = false
      @errors = []
    end

    def process(data, args, console)
      @console = console
      new_data = transform(data, args)

      { handled: handled?, success: success?, new_data:, errors: }
    end

    def transform(data, args)
      @hdata = data
      handle(args)
      @hdata
    end

    def handle(_args)
      raise 'Not immplemented: override thsi method in subclass'
    end

    def handled?
      raise 'Not immplemented: override thsi method in subclass'
    end

    def success?
      raise 'Not immplemented: override thsi method in subclass'
    end

    def e(msg)
      @errors.push(msg)
      false
    end

    def fine
      @errors = []
      true
    end
  end
end
