# require 'thread'
require 'pry'
module Airrecord
  class FaradayNaiveCache < Faraday::Middleware
    def initialize(app)
      super(app)
    end

    def call(env)
      #get from cache if we are loading an individual record
      if requesting_individual_record?
        (klass, id) = parse_klass_and_id(env)
        cached = try_cache()
        return cached unless cached.nil?
      end

      #otherwise do the request
      @app.call(env)
    end

    def parse_klass_and_id
      binding.pry
    end

    def requesting_individual_record?
      return true
    end

    def try_cache(klass, id)

      return nil
    end
  end
end

Faraday::Request.register_middleware(
  # Avoid polluting the global middleware namespace with a prefix.
  :airrecord_cache => Airrecord::FaradayNaiveCache
)
