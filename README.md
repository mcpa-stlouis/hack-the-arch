HackTheArch 
===========

[![Build Status](https://travis-ci.org/mcpa-stlouis/hack-the-arch.svg?branch=master)](https://travis-ci.org/mcpa-stlouis/hack-the-arch)
![Heroku](https://heroku-badge.herokuapp.com/?app=hackthearch&svg=1)
![Code Climate](https://codeclimate.com/github/mcpa-stlouis/hack-the-arch/badges/gpa.svg)
[![Coverage](https://coveralls.io/repos/github/mcpa-stlouis/hack-the-arch/badge.svg)](https://coveralls.io/github/mcpa-stlouis/hack-the-arch)

This is a scoring server built using Ruby on Rails by the Military Cyber
Professionals Association (MCPA).  It is free to use and extend under the MIT
license (see LICENSE file).  The goal of this project is to provide a standard
generic scoring server that provides an easy way to add and modify problems and
track statistics of a Cyber Capture the Flag event.  While it's not
recommended, this server can be hosted with your challenges but we do recommend
sand-boxing your challenges so they do not affect the scoring server.

**Want to see it in action?  Live Demo hosted
[here](https://hackthearch.herokuapp.com) and screenshots [here](https://github.com/mcpa-stlouis/hack-the-arch/wiki/Screenshots)!**

What's different about HackTheArch?
-----------------------------------
We created this application after using the [PicoCTF
platform](https://github.com/picoCTF/picoCTF-Platform-2) for our annual CTF.
It was okay, but we found it lacking some features that we wanted.  We wanted a
way to be able to offer competitors hints for a cost, and we also wanted a way
to create and modify problems from a web interface.  We looked around and
didn't see any others that met our requirements.
[CTFd](https://github.com/isislab/CTFd): at the time, had no web admin interface 
for creating challenges.  [Root The Box](https://github.com/moloch--/RootTheBox):
We didn't like all the extra stuff with the bank accounts and it just seemed too
complex for our needs.  So we decided to roll our own scoring server and now you
can benefit from our hard work!  This application implements an optional dynamic
hint system which will deduct points for requesting hints and also implements a
web interface for creating and modifying hints and challenges.  We hope you
enjoy this application and are open to feedback so let us know what you like,
hate, would like to see added, etc...

Requirements
------------
* Ruby version 3.1
* Activation and password reset e-mails depend on Heroku SendGrid add-on
  configuration (this feature can be optionally disabled or easily modified to
  be used with other mailers)
* To store challenge pictures in the production environment, you'll need to
  modify 'config/initializers/carrier\_wave.rb' to work with your cloud storage
  solution
* See Gemfile for further requirements

Deployment Options
==================
Manual Deployment
-----------------
* To manually deploy HackTheArch, be sure to download the latest stable release 
  [here](https://github.com/mcpa-stlouis/hack-the-arch/releases), or checkout
  the 'master' branch.  For the latest features and a less-stable version,
  checkout the 'dev' branch.  

Docker 
------
[![](https://images.microbadger.com/badges/image/paullj1/hackthearch.svg)](https://microbadger.com/images/paullj1/hackthearch)

* A Dockerfile is included along with a docker-compose.yml for deploying a
  containerized version of HackTheArch.  More detailed instructions can be
  found in: the [Docker README](https://github.com/mcpa-stlouis/hack-the-arch/blob/master/DOCKER_README.md).

Heroku
------
* A few things must be configured to deploy to Heroku:

  1.  Create a `HOST` environment variable that contains the url for your app
      (e.g., HOST=hackthearch.herokuapp.com).
  2.  For mailer support, add the sendgrid addon before deploying (`heroku
      addons:create sendgrid:starter`).  More info on Sendgrid
      [here](https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up).
  3.  For live streaming (submissions, chat, etc...), add the Redis To Go
      addon.
  
Notes
-----
* All deployments of HackTheArch require some a way to send account activation
  e-mails (or alternatively activation e-mails can be disabled in the admin
  console).  With Heroku, you can use the Sendgrid plugin, otherwise, you'll
  need to configure the mailer options in `config/environments/production.rb`.
* To initialize the database, run: `bundle exec rails db:seed`.  After
  initialization, the admin login credentials will be: **admin@gmail.com** :
  **password**
* **Important**: It is highly advised that you immediately change the admin
  credentials post-deployment
  * While any user may be made an admin, it can only be done manually in the
    database.  This is to prevent privilege escalation through the web interface.

### More configuration details on our project [wiki](https://github.com/mcpa-stlouis/hack-the-arch/wiki).

Contribute and Contact
======================
Want to help?
-------------
* Want to add a new feature or fix a bug? Check out a branch and submit working
  code with tests via pull request to merge into the 'dev' branch.
* Check out the [slack](https://hack-the-arch.slack.com) channel for more.
* Test coverage would be a good place to start: [here](coverage/index.html)

Contact
-------
* [Paul Jordan](http://paullj1.com) @ paullj1[at]gmail[dot]com
* [Raymond Evans](http://CyDefe.com) @ REvans[at]CyDefe[dot]com

Acknowledgements
----------------
* Base code derived from the [Rails Tutorial](http://railstutorial.org) by
  Michael Hartl
