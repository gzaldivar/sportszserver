module ContactsHelper

	def delete_contacts(siteid)
		Contact.where("siteid='#{siteid}'").each_with_index do |c, cnt|
			c.destroy
		end
	end
	
end
