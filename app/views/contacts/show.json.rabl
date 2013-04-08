object @contact
node(:id) { |o| o.id.to_s }
attributes :title, :name, :phone, :mobile, :fax, :email
