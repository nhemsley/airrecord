module Airrecord
  class Cache
    
    def initialize
      @cache = {}
    end

    def populate_objects_of_klass(klass, objects)
      @cache[klass] = {} if @cache[klass].nil?

      
    end
end