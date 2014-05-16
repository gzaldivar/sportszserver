class Gameschedule
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  attr_accessor :content_type, :original_filename, :image_data

  before_save :decode_base64_image
  before_create :set_live_game_time

  field :hideads, type: Boolean, default: false
  field :EditHomeScore, type: Boolean, default: false

  field :starttime, type: DateTime
  field :gamedate, type: Date
  field :location, type: String

  field :opponent_sport_id, type: String
  field :opponent_team_id, type: String
  field :useopponentstats, type: Boolean, default: false
  
  field :opponent, type: String
  field :opponent_mascot, type: String, default: ""
  field :opponent_league_wins, type: Integer, default: 0
  field :opponent_league_losses, type: Integer, default: 0
  field :opponent_nonleague_wins, type: Integer, default: 0
  field :opponent_nonleague_losses, type: Integer, default: 0
  field :opponent_nonleagueties, type: Integer, default: 0
  field :opponent_leagueties, type: Integer, default: 0

  field :event, type: String
  field :homeaway, type: String
  field :league, type: Boolean, default: false
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

  field :opponentscore, type: Integer, default: 0

  field :penalty, type: Integer, default: 0
  field :penaltyyards, type: Integer, default: 0
  field :livegametime, type: DateTime
  field :current_game_time, type: String, default: "15:00"
  field :own, type: Boolean, default: true
  field :our, type: String, default: ""
  field :ballon, type: Integer, default: 0
  field :possession, type: String, default: ""
  field :lastplay, type: String, default: ""
  field :down, type: Integer, default: 1
  field :togo, type: Integer, default: 0
  field :currentqtr, type: String, default: "Q1"

  field :final, type: Boolean, default: false
  field :mobilealerts, type: Boolean, default: false

  # generic game fields

  field :hometimeouts, type: Integer, default: 0
  field :opponenttimeouts, type: Integer, default: 0

  # Basketball fields

  field :bballpossessionarrow, type: String, default: "Home"
  field :opponentfouls, type: Integer, default: 0
  field :currentperiod, type: Integer, default: 1
  field :homebonus, type: Boolean, default: false
  field :visitorbonus, type: Boolean, default: false

  # Soccer fields
  field :socceroppsog, type: Integer, default: 0
  field :socceroppck, type: Integer, default: 0
  field :socceroppsaves, type: Integer, default: 0

  has_mongoid_attached_file :opponentpic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny     => ['50x50', :jpg],
      :thumb    => ['125x125', :jpg]
    }

  belongs_to :team, index: true

  has_many :gamelogs, dependent: :destroy
  has_many :blogs, dependent: :nullify
  has_many :photos, dependent: :nullify
  has_many :videoclips, dependent: :nullify
  has_many :basketball_stats, dependent: :destroy
  has_many :soccers, dependent: :destroy

  has_many :football_kickers, dependent: :destroy
  has_many :football_defenses, dependent: :destroy
  has_many :football_passings, dependent: :destroy
  has_many :football_place_kickers, dependent: :destroy
  has_many :football_punters, dependent: :destroy
  has_many :football_receivings, dependent: :destroy
  has_many :football_returners, dependent: :destroy
  has_many :football_rushings, dependent: :destroy
  has_many :events, dependent: :destroy

  embeds_one :lacross_game


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

  def set_live_game_time
    self.livegametime = Date.today.midnight
  end

  private

    def decode_base64_image
      if self.image_data && self.content_type && self.original_filename
#        decoded_data = Base64.decode64(self.image_data)
 
        data = StringIO.new(image_data)
        data.class_eval do
          attr_accessor :content_type, :original_filename
        end
 
        data.content_type = self.content_type
        data.original_filename = File.basename(self.original_filename)
 
        self.opponentpic = data
      end
    end

end
