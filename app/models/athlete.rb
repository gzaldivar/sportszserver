class Athlete
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Search

  attr_accessor :content_type, :original_filename, :image_data
  
  before_save :decode_base64_image
  after_save :send_alerts
  before_destroy :process_statslist
  
  field :number, type: Integer
  field :lastname, type: String
  field :firstname, type: String
  field :middlename, type: String
  field :position, type: String
  field :height, type: String
  field :weight, type: Integer
  field :year, type: String
  field :season, type: String
  field :bio, type: String
  field :followers, type: Hash, default: Hash[]
  field :fans, type: Array

  search_in :lastname, :firstname, :middlename, :number, :team, :position
  
  has_mongoid_attached_file :pic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
    					           secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny     => ['50x50',      :jpg],
      :thumb    => ['125x125',   :jpg],
      :medium   => ['320x480',    :jpg],
      :large    => ['640x960',    :jpg]
    }

    belongs_to :sport, index: true
    belongs_to :team
    has_many :photos
    has_many :football_stats, dependent: :destroy
    has_many :blogs
    has_many :newsfeeds
    has_many :alerts, dependent: :destroy
    has_many :basketball_stats, dependent: :destroy
    
    validates :number, presence: true, numericality: { greater_than: 0 }
    validates :lastname, presence: true, format: { with: /^[a-zA-Z\d\s]*$/ }
    validates :firstname, presence: true, format: { with: /^[a-zA-Z\d\s]*$/ }
    validates_presence_of :year
    validates_presence_of :season
    validates_attachment_content_type :pic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
    
    def full_name
      if middlename.nil?
        return number.to_s + " - " + lastname + ", " + firstname
      else
        return number.to_s + " - " + lastname + ", " + firstname + " " + middlename
      end
    end
    
    def name
      lastname + ", " + firstname + " " + middlename 
    end

    def logname
      firstname[0] + ". " + lastname
    end

    private

      def send_alerts
          self.fans.each do |user|
            if User.find(user).bio_alert?
              self.alerts.create!(sport: sport, user: user, message: "Athlete info updated")
            end
          end
      end

      def decode_base64_image
        if self.image_data && self.content_type && self.original_filename
          decoded_data = Base64.decode64(self.image_data)
   
          data = StringIO.new(decoded_data)
          data.class_eval do
            attr_accessor :content_type, :original_filename
          end
   
          data.content_type = self.content_type
          data.original_filename = File.basename(self.original_filename)
   
          self.pic = data
        end
      end

      def process_statslists
        self.sport.teams.each do |t|
          if !t.fb_pass_players.nil?
            t.fb_pass_players.delete_if{|x| x == self.id.to_s}
          end
          if !t.fb_def_players.nil?
            t.fb_def_players.delete_if{|x| x == self.id.to_s}
          end
          if !t.fb_rush_players.nil?
            t.fb_rush_players.delete_if{|x| x == self.id.to_s}
          end
          if !t.fb_spec_players.nil?
            t.fb_spec_players.delete_if{|x| x == self.id.to_s}
          end
          if !t.fb_rec_players.nil?
            t.fb_rec_players.delete_if{|x| x == self.id.to_s}
          end
          t.save!
        end
      end
end
