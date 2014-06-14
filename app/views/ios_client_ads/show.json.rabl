object @product
node(:id) { |o| o.id.to_s }
attributes :referencename, :productid, :adtype, :appleid, :price
node(:thumb) { |t| t.iosadimage(:thumb) }
node(:tiny) { |t| t.iosadimage(:tiny) }
node(:medium) { |t| t.iosadimage(:medium) }
