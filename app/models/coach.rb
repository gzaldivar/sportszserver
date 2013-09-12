class Coach
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Search

  attr_accessor :content_type, :original_filename, :image_data
  
  before_save :decode_base64_image

  field :lastname, type: String
  field :firstname, type: String
  field :middlename, type: String, default: ""
  field :speciality, type: String, default: ""
  field :years_on_staff, type: Integer
  field :bio, type: String, default: ""
    
  field :processing, type: Boolean, default: false
  
  search_in :lastname, :firstname, :middlename, :speciality
  
  has_mongoid_attached_file :coachpic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
    					           secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny     => ['50x50', :jpg],
      :thumb    => ['125x125',   :jpg],
      :medium   => ['320x480',    :jpg],
      :large    => ['640x960',   :jpg]
    }

    belongs_to :sport, index: true
    belongs_to :team, index: true
    has_many :blogs, dependent: :nullify
    has_many :newsfeeds, dependent: :nullify

    validates :lastname, presence: true, format: { with: /^[a-zA-Z\d\s]*$/ }
    validates :firstname, presence: true, format: { with: /^[a-zA-Z\d\s]*$/ }
    validates_attachment_content_type :coachpic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
    
    def full_name
      if middlename.nil?
        return lastname + ", " + firstname
      else
        return lastname + ", " + firstname + " " + middlename
      end
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
   
          self.coachpic = data
        end
      end
  
end
