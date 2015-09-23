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
						 team_id: 1,
 						 activated_at: Time.zone.now)

Setting.create!(name: "competition_name", value: "HackTheArch", setting_type: "text")
Setting.create!(name: "max_members_per_team", value: "5", setting_type: "text")
Setting.create!(name: "subtract_hint_points_before_solve", value: "true", setting_type: "boolean")
Setting.create!(name: "start_time", value: Time.zone.now.to_s, setting_type: "date")
Setting.create!(name: "end_time", value: (Time.zone.now + 24.hours).to_s, setting_type: "date")

Team.create!(name:  "admins",
 						 passphrase: "password",
 						 members: "1")

Bracket.create!(name: "Professional", priority: "10")
Bracket.create!(name: "College", priority: "5")
Bracket.create!(name: "High School", priority: "1")
