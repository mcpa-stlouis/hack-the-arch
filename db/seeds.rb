# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create!(fname:  "admin",
 						 lname: "user",
 						 email: "admin@gmail.com",
 						 password:              "password",
 						 password_confirmation: "password",
 						 admin: true,
 						 activated: true,
 						 activated_at: Time.zone.now)

Setting.create!(name: "competition_name", value: "HackTheArch")
Setting.create!(name: "max_members_per_team", value: "5")
Setting.create!(name: "start_time", value: Time.zone.now.to_s)
Setting.create!(name: "end_time", value: (Time.zone.now + 24.hours).to_s)

