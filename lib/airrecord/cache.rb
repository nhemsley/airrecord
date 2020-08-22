module Airrecord
  class Cache
    
    def initialize
      @cache = {}
    end

    def populate_objects_of_klass(klass, objects)
      @cache[klass] = {} if @cache[klass].nil?
    end

    def get(klass, id)
      return @cache[klass][id] if @cache.has_key?(klass)

      nil
    end

    def set(klass, id, payload)
      @cache[klass] = {} unless @cache.has_key?(klass)
      @cache[klass][id] = payload
    end

    #Cache a Table.all query
    def cache_klass
      return unless block_given?
      
      @@currently_caching = true
      results = yield
      @@currently_caching = false

    end

    class << self

      attr_accessor :global_cache, :currently_caching

      def enable
        @global_cache = Cache.new
      end

      def enabled?
        !@global_cache.nil?
      end

      def currently_caching?
        @@currently_caching
      end

    end
  end
end