class Gameschedule
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :starttime, type: DateTime
  field :gamedate, type: Date
  field :location, type: String
  field :opponent, type: String
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

#  field :firstdowns, type: Integer, default: 0
  field :penalty, type: Integer, default: 0
  field :penaltyyards, type: Integer, default: 0

  has_mongoid_attached_file :opponentpic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny     => ['50x50', :jpg]
    }

  belongs_to :team, index: true
  has_many :football_stats
  has_many :gamelogs, dependent: :destroy
  has_many :blogs
  has_many :photos
  has_many :videoclips
  has_many :basketball_stats

  attr_accessor :firstdowns
  
  validates_presence_of :starttime
  validates_presence_of :gamedate
  validates_presence_of :location
  validates_presence_of :opponent
  validates :homeaway, presence: true, format: { with: /Home|Away|home|away/ }
  validates_attachment_content_type :opponentpic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_numericality_of :homeq1, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :homeq2, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :homeq3, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :homeq4, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :opponentq1, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :opponentq2, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :opponentq3, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :opponentq4, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :homeh1, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :homeh2, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :opponenth1, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :opponenth2, message: "Value must be 0 or a number greater than 0"
  validates_numericality_of :penaltyyards, greater_than_or_equal_to: 0
  validates_numericality_of :penalty, greater_than_or_equal_to: 0
  validates_numericality_of :firstdowns, greater_than_or_equal_to: 0

  def game_name
    gamedate.strftime("%m/%d/%Y") + " vs " + opponent
  end

  def start_time
    starttime
  end

end
