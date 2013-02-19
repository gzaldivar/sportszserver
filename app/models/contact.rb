class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  field	:title,		type: String
	field	:name,		type: String
	field	:phone,		type: String
	field 	:mobile,	type: String
	field	:fax,		type: String
	field 	:email,		type: String

  belongs_to	:site, index: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates	:name, presence: true
  validates :title, presence: true
  validates :phone, format: { with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/ }
  validates :mobile, format: { with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/ }
  validates :fax, format: { with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/ }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    				uniqueness: { case_sensitive: false }
end
