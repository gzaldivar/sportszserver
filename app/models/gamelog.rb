class Gamelog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :logentry, type: String
  field :period, type: String
  field :time, type: String
  field :score, type: String

  embedded_in :gameschedule
#
  validates_presence_of :logentry
end
