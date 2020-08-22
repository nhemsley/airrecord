require "json"
require "faraday"
require "time"
require "airrecord/version"
require "airrecord/client"
require "airrecord/table"

module Airrecord
  extend self
  Error = Class.new(StandardError)
  attr_accessor :api_key
  attr_accessor :throttle
  attr_accessor :cache

  def throttle?
    return true if @throttle.nil?
    @throttle
  end

  def cache?
    return true if @cache
  end
end
