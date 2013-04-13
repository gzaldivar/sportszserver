class Sponsor
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :name, type: String
  field :addrnum, type: Integer
  field :street, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :phone, type: String
  field :fax, type: String
  field :mobile, type: String
  field :contactemail, type: String
  field :priority, type: Boolean, default: false
  field :teamonly, type: Boolean, default: false
  field :adurl, type: String

  belongs_to :team
  belongs_to :sport

  has_mongoid_attached_file :sponsorpic,
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

  validates_attachment_content_type :sponsorpic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_presence_of :name, :addrnum, :street, :state, :city, :zip, :contactemail, :adurl
  validates :phone, format: { with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})?([ .-]?)([0-9]{4})/ }
  validates_format_of :mobile, allow_blank: true, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})?([ .-]?)([0-9]{4})/  
  validates_format_of :fax, allow_blank: true, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})?([ .-]?)([0-9]{4})/  

end
