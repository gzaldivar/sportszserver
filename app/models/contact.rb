class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  field	:title,		type: String
	field	:name,		type: String
	field	:phone,		type: String
	field :mobile,	type: String
	field	:fax,		type: String
	field :email,		type: String

  belongs_to	:sport, index: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates	:name, presence: true
  validates :title, presence: true
  validates_format_of :phone, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, allow_nil: true, allow_blank: true
  validates_format_of :mobile, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, allow_nil: true, allow_blank: true
  validates_format_of :fax, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, allow_nil: true, allow_blank: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  
end
