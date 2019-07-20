# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# General Category
Setting.create!(label: "Competition Name:", 
                name: "competition_name", value: "HackTheArch", setting_type: "text", category: "General")
Setting.create!(label: "Competition Start Time:", 
                name: "start_time", value: DateTime.current.strftime("%m/%d/%Y %I:%M %p"), setting_type: "date", category: "General")
Setting.create!(label: "Competition End Time:", 
                name: "end_time", value: (DateTime.current + 1.days).strftime("%m/%d/%Y %I:%M %p"), setting_type: "date", category: "General")
Setting.create!(label: "Max number of members per team:", 
                name: "max_members_per_team", value: "5", setting_type: "text", category: "General")
Setting.create!(label: "Registration on?", 
                name: "registration_active", value: "0", setting_type: "boolean", category: "General")
Setting.create!(label: "Use bracket based handicap system?", 
                name: "use_bracket_handicaps", value: "0", setting_type: "boolean", category: "General")
Setting.create!(label: "Allow users to view profiles other than their own?", 
                name: "view_other_profiles", value: "1", setting_type: "boolean", category: "General")

# E-mail Category
Setting.create!(label: "Send activation e-mails?", tooltip: "Requires mailer config", 
                name: "send_activation_emails", value: "0", setting_type: "boolean", category: "E-Mail")
Setting.create!(label: "Require admin authorization for account creation?", tooltip: "Requires setting authorization e-mail",  
                name: "admin_account_auth", value: "0", setting_type: "boolean", category: "E-Mail")
Setting.create!(label: "Authorization e-mail", tooltip: "E-mail address where authorization requests will be sent",  
                name: "admin_auth_email", value: "contact.stlouis@milcyber.org", setting_type: "text", category: "E-Mail")
Setting.create!(label: "Contact e-mail", tooltip: "Will be used in emails and help/contact info on site",  
                name: "contact_email", value: "contact.stlouis@milcyber.org", setting_type: "text", category: "E-Mail")

# Scoring Category
Setting.create!(label: "Subtract hint deductions before problem is solved?", 
                name: "subtract_hint_points_before_solve", value: "1", setting_type: "boolean", category: "Scoring")
Setting.create!(label: "Scoreboard (on/off):", 
                name: "scoreboard_on", value: "1", setting_type: "boolean", category: "Scoring")
Setting.create!(label: "Maximum number of submissions per team:", tooltip: "per challenge; 0 means no limit",
                name: "max_submissions_per_team", value: "0", setting_type: "text", category: "Scoring")

# Console Category
Setting.create!(label: "Remote:", 
                tooltip: "Run <a href='https://code.google.com/archive/p/shellinabox/'>ShellInABox</a> as: 'shellinaboxd -s /:SSH:remote'", 
                name: "console_host", value: "https://localhost:4200", setting_type: "text", category: "Console")
Setting.create!(label: "Shellinabox Console enabled?", 
                name: "console_enabled", value: "0", setting_type: "boolean", category: "Console")
Setting.create!(label: "Docker Swarm Services Enabled?", 
                tooltip: "Assumes scoring service is run on a manager node with access to /var/run/docker.sock",
                name: "swarm_services_enabled", value: "0", setting_type: "boolean", category: "Console")

# Chat Category
Setting.create!(label: "Chat enabled?", 
                name: "chat_enabled", value: "1", setting_type: "boolean", category: "Chat")
Setting.create!(label: "Scoring notifications?", 
                name: "scoring_notifications", value: "1", setting_type: "boolean", category: "Chat")

# Payment Category
Setting.create!(label: "Require Payment?", tooltip: "Reqires 'stripe' configuration", 
                name: "require_payment", value: "0", setting_type: "boolean", category: "Payment")
Setting.create!(label: "Entry cost:", tooltip: "in $0.01 increments (e.g., 500 = $5.00 USD)", 
                name: "entry_cost", value: "500", setting_type: "text", category: "Payment")
Setting.create!(label: "50% Off Discount Code:", tooltip: "empty string disables", 
                name: "fifty_percent_off", value: "", setting_type: "text", category: "Payment")
Setting.create!(label: "100% Off Discount Code:", tooltip: "empty string disables", 
                name: "one_hundred_percent_off", value: "", setting_type: "text", category: "Payment")

bracket = Bracket.create!(name: "Professional", priority: "10", hints_available: 0)
          Bracket.create!(name: "College", priority: "5", hints_available: 2)
          Bracket.create!(name: "High School", priority: "1", hints_available: 4)

team = Team.create!(name:  "admins",
                    passphrase: "password",
                    bracket_id: bracket.id)

user = User.create!(id: Random.rand(10000),
                    fname:  "admin",
                    lname: "user",
                    username: "admin",
                    email: "admin@gmail.com",
                    password:              "password",
                    password_confirmation: "password",
                    admin: true,
                    activated: true,
                    paid: true,
                    team_id: team.id,
                    authorized: true,
                    authorized_at: Time.zone.now,
                    activated_at: Time.zone.now)

user.join_team(team)

hint = Hint.create!(hint: "The test was named after him",
                    points: "25",
                    priority: "1")

problem = Problem.create!(name: "Who's that scientist?",
                          points: "100",
                          category: "Trivia",
                          description: "What's the name of the scientist that invented the test to determine the ability of a machine to exhibit intelligent behavior equivalent to, or indistinguishable from, that of a human?",
                          solution: "Alan Turing",
                          correct_message: "Very good!",
                          false_message: "Try again!",
                          solution_case_sensitive: "1",
                          solution_regex: "0",
                          visible: "1")
problem.add(hint.id)

Problem.create!(name: "Google Foo",
                points: "100",
                category: "Network Exploitation",
                description: "What is the name of the site that indexes varios IoT devices like web cams and ethernet enabled thermostats?",
                solution: "Shodan",
                correct_message: "Scary, right!?",
                false_message: "Try again!",
                solution_case_sensitive: "1",
                solution_regex: "0",
                visible: "1")

