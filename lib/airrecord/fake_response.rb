module Airrecord
  class FakeResponse

    attr_accessor :body

    def initialize(body)
      @body = body
    end

    def success?
      true
    end
  
  end

end