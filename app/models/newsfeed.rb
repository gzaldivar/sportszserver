class Newsfeed
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::Paperclip

  attr_accessor :content_type, :original_filename, :image_data
  
  before_save :decode_base64_image

  field   :title, 		type: String
  field   :news,		type: String
  field   :external_url, type: String
  field   :owner,   type: String
  field   :allsports,	type: Boolean
  field   :processing, type: Boolean, default: false
  
  belongs_to :sport
  belongs_to :athlete
  belongs_to :coach
  belongs_to :team
  belongs_to :gameschedule
  belongs_to :videoclip
  
  index(  { team: 1 }, { unique: false } )
  index( { gameschedule: 1 } , { unique: false } )
  
  has_mongoid_attached_file :newsfeedpic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny     => ['50x50', :jpg],
      :thumb    => ['125x125',   :jpg]
    }

  validates_attachment_content_type :newsfeedpic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_presence_of :title
  
  search_in :title, :news
  
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
   
          self.newsfeedpic = data
        end
      end
end
