class Gameschedule
  include Mongoid::Document
  include Mongoid::Timestamps

  field :starttime, type: DateTime
  field :gamedate, type: Date
  field :location, type: String
  field :opponent, type: String
  field :event, type: String
  field :homeaway, type: String
  field :live, type: Boolean
  field :live_url, type: String

  belongs_to :team, index: true

  validates_presence_of :starttime
  validates_presence_of :gamedate
  validates_presence_of :location
  validates_presence_of :opponent
  validates :homeaway, presence: true, format: { with: /Home|Away|home|away/ }
  
  def game_name
    gamedate.strftime("%m/%d/%Y") + " " + opponent
  end

end
