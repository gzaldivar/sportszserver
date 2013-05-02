class Sport
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Search

  field :name, type: String
  field :sportname, type: String
  field :has_stats, type: Boolean, default: false
  field :year, type: String
  field :season, type: String
#  field :sex, type: String
  field :mascot, type: String
  field :sitename, type: String

  field :enable_user_pics,    type: Boolean
  field :enable_user_video,   type: Boolean
  field :review_media,      type: Boolean

  field :about_filename_url,  type: String
  field :about_filename,    type: String
  field :about_filetype,    type: String

  field :help_file_name,    type: String

  field :contactemail,      type: String
 
  field :zip,         type: String
  field :state,         type: String
  field :city,          type: String
  field :address,       type: String

  field :adminid, type: String
  field :tier, type: String, default: "Basic"
  field :mediasize, type: Integer, default: 0

  field :alert_interval, type: Integer, default: 120     # Time interval to check for alerts
  field :gamelog_interval, type: Integer, default: 360     # Time interval to check for game log updates
  field :newsfeed_interval, type: Integer, default: 3600  # Time interval to check for news feeds

  search_in :sitename, :mascot, :state, :zip, :city

#  belongs_to :site
  belongs_to :user
  has_many :contacts, dependent: :destroy
  has_many :newsfeeds, dependent: :destroy
  has_many :athletes, dependent: :destroy
  has_many :coaches, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :videoclips, dependent: :destroy
  has_many :photo_errors, dependent: :destroy
  has_many :photo_queues, dependent: :destroy
  has_many :sponsors, dependent: :destroy
  has_many :blogs, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :alerts
  embeds_many :teams

  has_mongoid_attached_file :sport_banner,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
    					           secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :original => ['1920x300', :jpg],
      :thumb    => ['125x50',   :jpg],
      :medium   => ['600x100',    :jpg],
      :large    => ['1000x150',   :jpg]
    }

  has_mongoid_attached_file :sport_logo,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
    					           secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
#      :original => ['1920x1680', :jpg],
      :thumb    => ['125x125',   :jpg],
      :medium   => ['320x480',    :jpg],
      :large    => ['640x960',   :jpg]
    }

  has_mongoid_attached_file :background,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
#      :original => ['1600x1000', :jpg],
      :thumb    => ['100x100',   :jpg],
      :medium   => ['320x480',    :jpg],
      :large    => ['640x960',   :jpg]
    }

  validates_presence_of :name, :sitename
  validates :zip, presence: true, format: { with: /^[0-9]{5}(-[0-9]{4})?$/ }

  validates :year, presence: true, format: { with: /^[0-9]{4}$/ }
  validates_presence_of :season
#  validates :sex, presence: true, format: { with: /Male|Female/ }
  validates :state, presence: true
  validates :contactemail, presence: true
   
  validates_attachment_content_type :sport_banner, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_attachment_content_type :sport_logo, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_attachment_content_type :background, content_type: ['image/jpg', 'image/jpeg', 'image/png']

  def sport_name
    if mascot.nil?
      if self.name.nil?
        sportname
      else
        self.name
      end
    else
      if self.name.nil?
        sportname + " " + mascot
      else
        self.name + " " + mascot
      end
    end
  end
  
end
