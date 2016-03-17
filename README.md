HackTheArch
===========

This is a scoring server built using Ruby on Rails by the Military Cyber Professionals Association (MCPA).  It is free to use and extend under the MIT license (see LICENSE file).  The goal of this project is to provide a standard generic scoring server that provides an easy way to add and modify problems and track statistics of a Cyber Capture the Flag event.  While it's not recommended, this server can be hosted with your challenges but we do recommend sand-boxing your challenges so they do not affect the scoring server.

**Want to see it in action?  Live Demo hosted [here](https://hta-demo.mcpa-stl.org)!**

What's different about HackTheArch?
-----------------------------------
We created this application after using the [PicoCTF platform](https://github.com/picoCTF/picoCTF-Platform-2) for our annual CTF.  It was okay, but we found it lacking some features that we wanted.  We wanted a way to be able to offer competitors hints for a cost, and we also wanted a way to create and modify problems from a web interface.  We looked around and didn't see any others that met our requirements.  [CTFd](https://github.com/isislab/CTFd): no web admin interface for creating challenges.  [Root The Box](https://github.com/moloch--/RootTheBox): We didn't like all the extra stuff with the bank accounts and it just seemed too complex for our needs.  So we decided to roll our own scoring server and now you can benefit from our hard work!  This application implements an optional dynamic hint system which will deduct points for requesting hints and also implements a web interface for creating and modifying hints and challenges.  We hope you enjoy this application and are open to feedback so let us know what you like, hate, would like to see added, etc...

Requirements
------------
* Ruby version 2.2.2p95
* Activation and password reset e-mails depend on Heroku SendGrid add-on configuration (this feature can be optionally disabled or easily modified to be used with other mailers)
* To store challenge pictures in the production environment, you'll need to modify 'config/initializers/carrier\_wave.rb' to work with your cloud storage solution
* See Gemfile for further requirements

Deployment Options
==================
Getting Started
---------------
* For the latest stable release either download the latest tagged release [here](https://github.com/mcpa-stlouis/hack-the-arch/releases), or checkout the 'master' branch.  For the latest features and a less-stable version, checkout the 'dev' branch.
* This app is presently designed to be deployed in a heroku environment.  You'll need to add the sendgrid addon before deploying (`heroku addons:create sendgrid:starter`) and update the host to match your domain in 'config/environments/production.rb'.  To deploy to Heroku, see their help page [here](https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up)
* It can be deployed outside a heroku environment but will require some alternative for sending account activation e-mails (or alternatively activation e-mails can be disabled in the admin console)
* To initialize the database, run: `bundle exec rake db:seed`.  After initialization, the admin login credentials will be: **admin@gmail.com** : **password**
* **Important**: It is highly advised that you change the admin credentials post-deployment

Quick Start (Simple Local Deployment)
------------------------------
Tested using Ubuntu Server 15.10.
* We recommend you remove the debug box in: `app/views/layouts/application.html.erb`
* Install the following packages `gcc make ruby ruby2.2 bundler zlib1g-dev postgresql-server-dev-all libsqlite3-dev nodejs`
* Run: `rake db:seed`
* Run: `sudo rails server -p 80 -b 0.0.0.0 -d`

Production (Advanced Local Deployment)
--------------------------------------
* Deploying HackTheArch in a production environment will provide a much more robust service but requires slightly more advanced configuration.
* Fill in variables and follow instructions in `OfflineSetup/start_local`
* Once the `start_local` script is complete, it can simply be run to start the server.

### More configuration details on our project [wiki](https://github.com/mcpa-stlouis/hack-the-arch/wiki).


Contribute and Contact
======================
Want to help?
-------------
* Want to add a new feature or fix a bug? Check out a branch and submit working code with tests via pull request to merge into the 'dev' branch.
* Test coverage would be a good place to start: [here](coverage/index.html)

Contact
-------
* [Paul Jordan](http://paullj1.com) @ paullj1[at]gmail[dot]com
* [Raymond Evans](http://CyDefe.com) @ REvans[at]CyDefe[dot]com

Acknowledgements
----------------
* Base code derived from the [Rails Tutorial](http://railstutorial.org) by Michael Hartl
