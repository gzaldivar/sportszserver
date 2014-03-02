class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :name, type: String
  field :desc, type: String
  field :duration, type: Float
  field :videoevent, type: Integer, default: 0  # 0 not a video event, 1 = live, 2 = local file, 3 = downloaded file
  field :eventurl, type: String
 
  attr_accessor :date_string, :string_date

  belongs_to :sport
  belongs_to :team
  belongs_to :user
  belongs_to :gameschedule

  validates_presence_of :name, :start_time, :end_time

end
