class Team
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  attr_accessor :content_type, :original_filename, :image_data

  before_save :decode_base64_image
  
  field :title, type: String
  field :mascot, type: String

  field :fb_pass_players, type: Array    # List of players user has for stat console
  field :fb_rush_players, type: Array    # List of players user has for stat console
  field :fb_rec_players, type: Array    # List of players user has for stat console
  field :fb_def_players, type: Array    # List of players user has for stat console
  field :fb_spec_players, type: Array    # List of players user has for stat console
  field :placekicker, type: String
  field :kicker, type: String
  field :punter, type: String

  has_mongoid_attached_file :team_logo,
  :storage        => :s3,
  :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                       access_key_id: S3DirectUpload.config.access_key_id,
                       secret_access_key: S3DirectUpload.config.secret_access_key },
  :styles => {
    :thumb    => ['125x125',   :jpg]
  }

  validates_presence_of :title
  validates_attachment_content_type :team_logo, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_presence_of :mascot

  embedded_in :sport
  has_many :gameschedules, dependent: :destroy
  has_many :sponsors, dependent: :destroy
  has_many :coaches
  has_many :athletes
  has_many :events
  has_many :blogs
  has_many :newsfeeds
    
  def team_name
    title + " " + mascot
  end

  private

      def decode_base64_image
        if self.image_data && self.content_type && self.original_filename
          decoded_data = Base64.decode64(self.image_data)
   
          data = StringIO.new(decoded_data)
          data.class_eval do
            attr_accessor :content_type, :original_filename
          end
   
          data.content_type = self.content_type
          data.original_filename = File.basename(self.original_filename)
   
          self.team_logo = data
        end
      end
end
