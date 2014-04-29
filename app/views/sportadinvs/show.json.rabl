object @sportadinv
node(:id) { |o| o.id.to_s }
attributes :price, :adlevelname, :active, :expiration, :playerad
node (:sport_id) { |s| s.id.to_s }
