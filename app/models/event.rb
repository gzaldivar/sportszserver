class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :start_time, type: DateTime
  field :startdate, type: Date
  field :end_time, type: DateTime
  field :enddate, type: Date
  field :name, type: String
  field :desc, type: String
  field :owner, type: String
  field :team, type: String

  belongs_to :sport

  validates_presence_of :name, :start_time, :end_time, :owner

end
