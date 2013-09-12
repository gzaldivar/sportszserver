class Videoclip
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  
  after_save :send_alerts
  before_destroy :deleteclips
  
  field :filename, type: String
  field :filepath, type: String
  field :filesize, type: String
  field :filetype, type: String

  field :video_url, type: String
  field :poster_url, type: String
  field :poster_filepath, type: String
  
  field :resolution,  type: String
  field :height,  type: Integer
  field :width, type: Integer
  field :size, type: Integer
  field :bitrate,   type: Integer
  field :duration, type: Float
  field :frame_rate, type: Float

  field :displayname, type: String
  field :description, type: String

  field :error_status, type: Boolean
  field :error_message, type: String
  field :pending, type: Boolean, default: false


  field :teamid,  type: String
  field :players, type: Array
  
  search_in :players, :displayname
  
  belongs_to :sport, index: true
  belongs_to :gameschedule
  belongs_to :user
  belongs_to :gamelog
  has_many :alerts, dependent: :destroy
  
  index( { teamid: 1 }, { unique: false } )

  validates_presence_of :filename

  def videopath
    "#{Rails.root}/tmp"
  end

  def deleteclips
    s3 = AWS::S3.new
    bucket = s3.buckets[S3DirectUpload.config.bucket]
    bucket.objects[self.filepath].delete
    bucket.objects[self.poster_filepath].delete
  end

  private

    def send_alerts
        if !self.players.nil?
            self.players.each do |p|
              player = Athlete.find(p)
              player.fans.each do |user|
                if User.find(user).media_alert?
                  player.alerts.create!(sport: sport, user: user, videoclip: self.id, message: "Video Clip Updated")
                end
              end
            end
        end
    end

end
