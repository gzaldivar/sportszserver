class ReceivingPlay
  include Mongoid::Document
  include Mongoid::Timestamps

  field :score, type: String
  field :time, type: String
  field :quarter, type: String
  field :yards, type: Integer
  field :entry, type: String

  embedded_in :football_receiving

  validates_numericality_of :yards, greater_than_or_equal_to: 0

end
