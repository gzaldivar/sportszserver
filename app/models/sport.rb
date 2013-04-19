class Sport
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

 
  field :name, type: String
  field :sportname, type: String
  field :has_stats, type: Boolean, default: false
  field :year, type: String
  field :season, type: String
  field :sex, type: String
  field :mascot, type: String

  belongs_to :site
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

  validate :nameofsport
#  validates_presence_of :name
  validates :year, presence: true, format: { with: /^[0-9]{4}$/ }
  validates_presence_of :season
  validates :sex, presence: true, format: { with: /Male|Female/ }
  validates_attachment_content_type :sport_banner, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_attachment_content_type :sport_logo, content_type: ['image/jpg', 'image/jpeg', 'image/png']
   
  def sport_name
    if mascot.nil?
      if name.nil?
        sportname
      else
        name
      end
    else
      if name.nil?
        sportname + " " + mascot
      else
        name + " " + mascot
      end
    end
  end

  private
    def nameofsport
      if self.sportname.blank? and self.name.blank?
        errors.add(:sports, "Sport name cannot be blank")
      end
    end
  
end
