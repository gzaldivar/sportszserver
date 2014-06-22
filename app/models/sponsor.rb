class Sponsor
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  attr_accessor :content_type, :original_filename, :image_data, :imagetype

  before_save :decode_base64_image

  field :name, type: String
  field :addrnum, type: Integer, default: 0
  field :street, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :phone, type: String
  field :fax, type: String
  field :mobile, type: String
  field :contactemail, type: String
  field :teamonly, type: Boolean, default: false
  field :adurl, type: String
  field :sponsorlevel, type: String
  field :adminentered, type: Boolean, default: false

  field :processing, type: Boolean, default: false

  field :sharepaid, type: Boolean, default: true
  field :sharetime, type: DateTime

  belongs_to :team
  belongs_to :sport
  belongs_to :sportadinv
  belongs_to :user
  belongs_to :athlete
  has_one :adpayment
  belongs_to :ios_client_ad

  has_mongoid_attached_file :sponsorpic,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :tiny     => ['50x50',     :jpg],
      :thumb    => ['125x125',   :jpg],
      :medium   => ['300x250',   :jpg],
      :large    => ['500x400',   :jpg]
    }

  has_mongoid_attached_file :adbanner,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key },
    :styles => {
      :landscapebanner  => ['768x100',   :jpg],
      :portraitbanner   => ['320x50',   :jpg]
    }

  validates_attachment_content_type :sponsorpic, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_attachment_content_type :adbanner, content_type: ['image/jpg', 'image/jpeg', 'image/png']
  validates_presence_of :name
  validates :phone, format: { with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})?([ .-]?)([0-9]{4})/ }
  validates_format_of :mobile, allow_blank: true, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})?([ .-]?)([0-9]{4})/  
  validates_format_of :fax, allow_blank: true, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})?([ .-]?)([0-9]{4})/

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
#      csv = []
#      csv += [:name, :addrnum, :street, :city, :state, :zip, :phone, :mobile, :fax, :contactemail, :adurl, :updated_at].map { |f| self[f] }
      if self.sportadinv.nil?
        csv += [:price].map { |f| self.sportadinv[f] }
      elsif self.ios_client_ad.nil?
        csv += [:price].map { |f| self.ios_client_ad[f] }
      end

      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
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
 
        if self.imagetype == "sponsorbanner"
          self.adbanner = data
        else
          self.sponsorpic = data
        end
      end
    end

end
