class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :start_time, type: DateTime
#  field :startdate, type: Date
  field :end_time, type: DateTime
#  field :enddate, type: Date
  field :name, type: String
  field :desc, type: String

  attr_accessor :date_string, :string_date

  belongs_to :sport
  belongs_to :team
  belongs_to :user

  validates_presence_of :name, :start_time, :end_time, :owner

end
