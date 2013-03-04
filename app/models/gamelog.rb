class Gamelog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :logentry, type: String
  field :period, type: Integer
  field :time, type: String
  field :score, type: Integer

  embedded_in :gameschedule

  validates_presence_of :logentry
end
