class Coach
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Search

  field :lastname, type: String
  field :firstname, type: String
  field :middlename, type: String
  field :speciality, type:String
  field :years_on_staff, type: Integer
  field :bio, type: String
  field :team, type: String,  default: "Unassigned"
  
  search_in :lastname, :firstname, :middlename, :speciality
  
  has_mongoid_attached_file :coachpic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
    					           secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :original => ['1920x1680', :jpg],
      :thumb    => ['125x125',   :jpg],
      :medium   => ['320x480',    :jpg],
      :large    => ['640x960',   :jpg]
    }

    belongs_to :sport, index: true

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
  
end
