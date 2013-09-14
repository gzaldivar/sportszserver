class Gameschedule
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  before_create :set_live_game_time

  field :starttime, type: DateTime
  field :gamedate, type: Date
  field :location, type: String
  field :opponent, type: String
  field :opponent_mascot, type: String, default: ""
  field :event, type: String
  field :homeaway, type: String
  field :live, type: Boolean
  field :live_url, type: String

  field :homeq1, type: Integer, default: 0
  field :homeq2, type: Integer, default: 0
  field :homeq3, type: Integer, default: 0
  field :homeq4, type: Integer, default: 0
  field :homeh1, type: Integer, default: 0
  field :homeh2, type: Integer, default: 0
  field :opponentq1, type: Integer, default: 0
  field :opponentq2, type: Integer, default: 0
  field :opponentq3, type: Integer, default: 0
  field :opponentq4, type: Integer, default: 0
  field :opponenth1, type: Integer, default: 0
  field :opponenth2, type: Integer, default: 0

  field :homescore, type: Integer, default: 0
  field :opponentscore, type: Integer, default: 0

#  field :firstdowns, type: Integer, default: 0
  field :penalty, type: Integer, default: 0
  field :penaltyyards, type: Integer, default: 0
  field :livegametime, type: DateTime
  field :current_game_time, type: String
  field :own, type: Boolean, default: true
  field :our, type: String, default: ""
  field :ballon, type: Integer, default: 0
  field :possession, type: String, default: ""
  field :lastplay, type: String, default: ""
  field :down, type: Integer, default: 1
  field :togo, type: Integer, default: 0
  field :currentqtr, type: String, default: "Q1"

  field :final, type: Boolean, default: false

  # generic game fields

  field :hometimeouts, type: Integer, default: 0
  field :opponenttimeouts, type: Integer, default: 0

  # Basketball fields

  field :bballpossessionarrow, type: String, default: "Home"
  field :homefouls, type: Integer, default: 0
  field :opponentfouls, type: Integer, default: 0
  field :currentperiod, type: Integer, default: 1

  has_mongoid_attached_file :opponentpic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny     => ['50x50', :jpg]
    }

  belongs_to :team, index: true
  has_many :football_stats, dependent: :destroy
  has_many :gamelogs, dependent: :destroy
  has_many :blogs, dependent: :nullify
  has_many :photos, dependent: :nullify
  has_many :videoclips, dependent: :nullify
  has_many :basketball_stats, dependent: :destroy

  attr_accessor :firstdowns
  
  validates_presence_of :starttime
  validates_presence_of :gamedate
  validates_presence_of :location
  validates_presence_of :opponent
  validates :homeaway, presence: true, format: { with: /Home|Away|home|away/ }
#  validates :bballpossessionarrow, format: { with: "/Home|Visitor/" }, allow_nil: true
  validates_attachment_content_type :opponentpic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_numericality_of :homeq1, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :homeq2, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :homeq3, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :homeq4, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :opponentq1, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :opponentq2, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :opponentq3, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :opponentq4, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :homeh1, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :homeh2, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :opponenth1, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :opponenth2, message: "Value must be 0 or a number greater than 0", greater_than_or_equal_to: 0
  validates_numericality_of :penaltyyards, greater_than_or_equal_to: 0
  validates_numericality_of :penalty, greater_than_or_equal_to: 0
  validates_numericality_of :togo, greater_than_or_equal_to: 0
  validates_numericality_of :down, greater_than_or_equal_to: 0
  validates_numericality_of :ballon, greater_than_or_equal_to: 0

  def game_name
    gamedate.strftime("%m/%d/%Y") + " vs " + opponent
  end

  def opponent_name
    opponent + " " + opponent_mascot
  end

  def start_time
    starttime
  end

  def set_live_game_time
    self.livegametime = Date.today.midnight
  end

end
