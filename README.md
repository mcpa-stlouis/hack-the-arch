README - Hack the Arch
======================

This is a scoring server built using Ruby on Rails by the Military Cyber Professionals Association (MCPA).  It is free to use and extend under the MIT license (see LICENSE file).  The goal of this project is to provide a standard generic scoring server that provides an easy way to add and modify problems and track statistics of a Cyber Capture the Flag event.  While it's not recommended, this server can be hosted with your challenges but we do recommend sand-boxing your challenges so they do not affect the scoring server.

Requirements
------------
* Ruby version 2.2.2p95
* See Gemfile for further requirements

Getting Started
---------------
* This app is presently designed to be deployed in a heroku environment.  You'll need to add the sendgrid addon before deploying (heroku addons:create sendgrid:starter) and update the host to match your domain in 'config/environments/production.rb'.

Contact
-------
* [Paul Jordan](http://paullj1.com) @ paullj1[at]gmail[dot]com

Acknowledgements
----------------
* Base code derived from the [Rails Tutorial](http://railstutorial.org) by Michael Hartl
