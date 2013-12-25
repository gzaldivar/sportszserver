class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  attr_accessor :content_type, :original_filename, :image_data

  before_save :decode_base64_image
  
  field :title, type: String
  field :mascot, type: String

  field :featuredplayers, type: Array
  field :featuredphotos, type: Array
  field :featuredvideoclips, type: Array

  field :fb_pass_players, type: Array    # List of players user has for stat console
  field :fb_rush_players, type: Array    # List of players user has for stat console
  field :fb_rec_players, type: Array    # List of players user has for stat console
  field :fb_def_players, type: Array    # List of players user has for stat console
  field :fb_placekickers, type: Array
  field :fb_kickers, type: Array
  field :fb_punters, type: Array
  field :fb_returners, type: Array

  field :logoprocessing, type: Boolean, default: false

  has_mongoid_attached_file :team_logo,
  :storage        => :s3,
  :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                       access_key_id: S3DirectUpload.config.access_key_id,
                       secret_access_key: S3DirectUpload.config.secret_access_key },
  :styles => {
    :tiny     => ['50x50',     :jpg],
    :thumb    => ['125x125',   :jpg]
  }

  validates_presence_of :title
  validates_attachment_content_type :team_logo, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_presence_of :mascot

  embedded_in :sport
  has_many :gameschedules, dependent: :destroy
  has_many :sponsors, dependent: :destroy
  has_many :coaches, dependent: :nullify
  has_many :athletes, dependent: :nullify
  has_many :events, dependent: :destroy
  has_many :blogs, dependent: :destroy
  has_many :newsfeeds, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :videoclips, dependent: :destroy
    
  def team_name
    title + " " + mascot
  end

  private

      def decode_base64_image
        if self.image_data && self.content_type && self.original_filename
#          decoded_data = Base64.decode64(self.image_data)
   
          data = StringIO.new(image_data)
          data.class_eval do
            attr_accessor :content_type, :original_filename
          end
   
          data.content_type = self.content_type
          data.original_filename = File.basename(self.original_filename)
   
          self.team_logo = data
        end
      end
end
