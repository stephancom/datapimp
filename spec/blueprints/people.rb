Person.blueprint do
  name { Faker::Name.name }
  salary { 30000 + (sn.to_i * 1000) }
end
