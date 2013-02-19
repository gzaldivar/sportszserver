require 'spec_helper'

describe Contact do
  
    before(:each) do
	    @attr = {
	      :title => "Head Coach",
	      :name => "Gil Zaldivar",
	      :phone => "949-632-6440",
	      mobile: "123-456-7890",
	      :fax => "949-123-4567",
	      email: "guest@example.com"
	    }
  	end

  it "should create a new instance given a valid attribute" do
    Contact.create!(@attr)
  end

  it "should require an email address" do
    no_email_user = Contact.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = Contact.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = Contact.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should require a title" do
  	no_title = Contact.new(@attr.merge(title: ""))
  	no_title.should_not be_valid
  end

  it "should require a name" do
  	no_name = Contact.new(@attr.merge(name: ""))
  	no_name.should_not be_valid
  end

end
