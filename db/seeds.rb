# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Setting.create!(name: "competition_name", value: "HackTheArch", setting_type: "text")
Setting.create!(name: "max_members_per_team", value: "5", setting_type: "text")
Setting.create!(name: "subtract_hint_points_before_solve", value: "true", setting_type: "boolean")
Setting.create!(name: "scoreboard_on", value: "true", setting_type: "boolean")
Setting.create!(name: "start_time", value: Time.zone.now.to_s, setting_type: "date")
Setting.create!(name: "end_time", value: (Time.zone.now + 24.hours).to_s, setting_type: "date")

bracket = Bracket.create!(name: "Professional", priority: "10")
          Bracket.create!(name: "College", priority: "5")
          Bracket.create!(name: "High School", priority: "1")

team = Team.create!(name:  "admins",
 						 				passphrase: "password",
 						 				bracket_id: bracket.id)

user = User.create!(id: Random.rand(10000),
						 				fname:  "admin",
 						 				lname: "user",
 						 				email: "admin@gmail.com",
 						 				password:              "password",
 						 				password_confirmation: "password",
 						 				admin: true,
 						 				activated: true,
						 				team_id: team.id,
 						 				activated_at: Time.zone.now)

team.add(user)

hint = Hint.create!(hint: "The test was named after him",
						 				points: "25",
						 				priority: "1")

Problem.create!(name: "Who's that scientist?",
								points: "100",
								category: "Trivia",
								description: "What's the name of the scientist that invented the test to determine the ability of a machine to exhibit intelligent behavior equivalent to, or indistinguishable from, that of a human?",
    						solution: "Alan Turing",
    						correct_message: "Very good!",
    						false_message: "Try again!",
    						hints: hint.id)

Problem.create!(name: "Google Foo",
								points: "100",
								category: "Network Exploitation",
								description: "What is the name of the site that indexes varios IoT devices like web cams and ethernet enabled thermostats?",
    						solution: "Shodan",
    						correct_message: "Scary, right!?",
    						false_message: "Try again!")

