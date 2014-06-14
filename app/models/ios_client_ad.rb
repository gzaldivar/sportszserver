class IosClientAd
	include Mongoid::Document
	include Mongoid::Paperclip

	field :referencename, type: String
	field :productid, type: String
	field :adtype, type: String
	field :appleid, type: String
	field :price, type: Float, default: 0.0

	belongs_to :admin

	has_mongoid_attached_file :iosadimage,
	    :storage        => :s3,
	    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
	                         access_key_id: S3DirectUpload.config.access_key_id,
	    					           secret_access_key: S3DirectUpload.config.secret_access_key },
	    :styles => {
	      	:tiny     => ['50x50', :jpg],
	      	:thumb    => ['125x125',   :jpg],
	      	:medium   => ['300x250',    :jpg],
	    }

end