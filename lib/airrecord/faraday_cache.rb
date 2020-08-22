require_relative 'fake_response'

module Airrecord
  class FaradayCache < Faraday::Middleware
    def initialize(app, record_into_cache: false)
      super(app)
    end

    def call(env)
      puts env.url.to_s
      # binding.pry
      #get from cache if we are loading an individual record
      if requesting_individual_record?(env)
        (klass, id) = parse_klass_and_id_from_single_object_request(env)
        klass = get_matching_airrecord_table_subclass(klass)
        cached = try_cache(klass, id)
        return Airrecord::FakeResponse.new(JSON.dump(cached)) unless cached.nil?
      end

      #otherwise do the request
      response = @app.call(env)

      cache_objects_in_response(response, env) if Airrecord::Cache.currently_caching?

      response

    end

    def cache_objects_in_response(response, env)
      # binding.pry

      klass_name = parse_klass_from_plural_request(env)
      klass = get_matching_airrecord_table_subclass(klass_name)
      binding.pry if klass.nil?
      payload = JSON.load(response.body)
      payload['records'].each do |record|
        puts "Caching #{klass}, #{record['id']}"
        Airrecord::Cache.global_cache.set(klass, record['id'], record)
      end
    end

    def get_matching_airrecord_table_subclass(klass_name)
      get_airrecord_table_subclasses.find do |subklass| 
        (subklass.table_name || subklass.to_s.split('::').last) == klass_name
      end
    end

    def get_airrecord_table_subclasses
      subclasses = Airrecord::Table.subclasses
      subclasses.concat subclasses.map{ |subclass| subclass.subclasses }.flatten
      subclasses
    end

    def parse_klass_from_plural_request(env)
      klass_name = env.url.to_s.split('/').last[0..-1]

    end

    def parse_klass_and_id_from_single_object_request(env)
      parts = env.url.to_s.split('/')
      (id, klass) = parts.reverse.take(2)
      return [klass, id]
    end

    def requesting_individual_record?(env)
      env.url.to_s[-1] != 's'
    end

    def requesting_records?(env)
      last_part = env.url.to_s.split('/').last
    end

    def try_cache(klass, id)
      return unless Airrecord::Cache.enabled?

      return Airrecord::Cache.global_cache.get(klass, id)
    end
  end
end

Faraday::Request.register_middleware(
  # Avoid polluting the global middleware namespace with a prefix.
  :airrecord_cache => Airrecord::FaradayCache
)
