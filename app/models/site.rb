class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Search

  field :sitename,				type: String
  field :mascot,				type: String
  
  field :enable_user_pics,		type: Boolean
  field :enable_user_video,		type: Boolean
  field :review_media,			type: Boolean

  field :about_filename_url,	type: String
  field :about_filename,		type: String
  field :about_filetype,		type: String

  field :help_file_name,		type: String

  field :contactemail,			type: String
 
  field :zip,					type: String
  field :state,					type: String
  field :city,					type: String
  field :address,				type: String

  field :sportsexdefault,    	type: String, default:  "Male"
  field :season,				type: String
  field :adminid, type: String
  field :tier, type: String, default: "Basic"
  field :mediasize, type: Integer, default: 0

  search_in :sitename, :mascot, :state, :zip, :city

  has_mongoid_attached_file :banner,
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

  has_mongoid_attached_file :logo,
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

  has_mongoid_attached_file :site_background,
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

  has_many :contacts, dependent: :destroy
  has_many :sports, dependent: :destroy
  belongs_to :user

  validates :zip, presence: true, format: { with: /^[0-9]{5}(-[0-9]{4})?$/ }
  validates :sitename, presence: true
  validates :state, presence: true
  validates :contactemail, presence: true

  validates_attachment_content_type :banner, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_attachment_content_type :logo, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_attachment_content_type :site_background, content_type: ['image/jpg', 'image/jpeg', 'image/png']

  attr_accessible :sitename, :mascot, :enable_user_video, :enable_user_pics, :banner, :logo, :background, :zip, :state, :city, :address

end
