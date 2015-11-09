README - Hack the Arch
======================

This is a scoring server built using Ruby on Rails by the Military Cyber Professionals Association (MCPA).  It is free to use and extend under the MIT license (see LICENSE file).  The goal of this project is to provide a standard generic scoring server that provides an easy way to add and modify problems and track statistics of a Cyber Capture the Flag event.  While it's not recommended, this server can be hosted with your challenges but we do recommend sand-boxing your challenges so they do not affect the scoring server.

What's different about HackTheArch?
-----------------------------------
We created this application after using the PicoCTF platform for our annual CTF.  It was okay, but we found it lacking some features that we wanted.  We wanted a way to be able to offer competitors hints for a cost, and we also wanted a way to create and modify problems from a web interface.  We looked around and didn't see any others that met our requirements.  CTFd: no web admin interface for creating challenges.  Root The Box: We didn't like all the extra stuff with the bank accounts and it just seemed too complex for our needs.  So we decided to roll our own scoring server and now you can benefit from our hard work!  This application implements an optional dynamic hint system which will deduct points for requesting hints and also implements a web interface for creating and modifying hints and challenges.  We hope you enjoy this application and are open to feedback so let us know what you like, hate, would like to see added, etc...

Requirements
------------
* Ruby version 2.2.2p95
* Activation and password reset e-mails depend on SendGrid configuration
* To store challenge pictures in the production environment, you'll need to modify 'config/initializers/carrier\_wave.rb' to work with your cloud storage solution
* See Gemfile for further requirements

Getting Started
---------------
* For the latest stable release either download the release, or checkout the 'master' branch.  For the latest features and a beta version, checkout the 'dev' branch.
* This app is presently designed to be deployed in a heroku environment.  You'll need to add the sendgrid addon before deploying (heroku addons:create sendgrid:starter) and update the host to match your domain in 'config/environments/production.rb'.  To deploy to Heroku, see their help page [here](https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up).
* It can be deployed outside a heroku environment but will require some alternative for sending account activation e-mails
* To initialize the database, run: `bundle exec rake db:seed`.  After initialization, the admin login credentials will be: **admin@gmail.com** : **password**
* **Important**: It is highly advised that you change the admin credentials post-deployment

Quick Start (Local Deployment)
------------------------------
Tested using Ubuntu Server 15.10.
* We recommend you remove the debug box in: 'app/views/layouts/application.html.erb'
* Install the following packages 'gcc make ruby ruby2.2 bundler zlib1g-dev postgresql-server-dev-all libsqlite3-dev nodejs'
* Run "rake db:seed"
* Run "sudo rails server -p 80 -b 0.0.0.0 -d"

Contact
-------
* [Paul Jordan](http://paullj1.com) @ paullj1[at]gmail[dot]com

Acknowledgements
----------------
* Base code derived from the [Rails Tutorial](http://railstutorial.org) by Michael Hartl
