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
  embeds_many :gamelogs
  has_many :blogs
  has_many :gameschedules
  has_many :photos
  has_many :videoclips

  validates_presence_of :starttime
  validates_presence_of :gamedate
  validates_presence_of :location
  validates_presence_of :opponent
  validates :homeaway, presence: true, format: { with: /Home|Away|home|away/ }
  validates_attachment_content_type :opponentpic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  
  def game_name
    gamedate.strftime("%m/%d/%Y") + " vs " + opponent
  end

  def start_time
    starttime
  end

end
