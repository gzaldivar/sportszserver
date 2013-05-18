class User
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String

  before_save :ensure_authentication_token

#  has_many :sites
  has_many :sports
  has_many :alerts
  has_many :photos
  has_many :videoclips
  has_many :newsfeeds
  has_many :events
  has_many :blogs

  index({ email: 1 }, { unique: true, background: true })
  field :name
  field :admin, type: Boolean, default: false
  field :mysites, type: Hash
  field :default_site, type: String
  field :teamid, type: String
  field :is_active, type: Boolean, default: true

  # Alert levels 

  field :bio_alert, type: Boolean, default: true
  field :media_alert, type: Boolean, default: true
  field :blog_alert, type: Boolean, default: true
  field :stat_alert, type: Boolean, default: true
  field :score_alert, type: Boolean, default: true

  has_mongoid_attached_file :avatar,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
    					           secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny    => ['50x50',   :jpg],
      :thumb    => ['100x100',   :jpg]
    }
    
  validates_attachment_content_type :avatar, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_presence_of :name
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :created_at, :updated_at, 
                  :authentication_token, :teamid, :avatar, :is_active, :bio_alert, :blog_alert, :media_alert, 
                  :stat_alert, :score_alert

   def active_for_authentication?
    super and self.is_active?
  end

#  StringIO.open(Base64.decode64(self.avatar_base64)) do |data|
#      data.original_filename = "image_name.jpg"
#      data.content_type = "image/jpeg"
#      self.avatar = data
#    end

end
