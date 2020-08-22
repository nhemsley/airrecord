require 'securerandom'
require 'test_helper'

class Walrus < Airrecord::Table
  self.base_key = 'app1'
  self.table_name = 'walruses'

  has_many :feet, class: 'Foot', column: 'Feet'
end

class Foot < Airrecord::Table
  self.base_key = 'app1'
  self.table_name = 'foot'

  belongs_to :walrus, class: 'Walrus', column: 'Walrus'
end