Offline Setup Instructions
==========================

There are two ways of running a local deployment of HackTheArch.

* Production mode:
------------------
Fill in the variables in the `start_local` script (in this directory) and then run it

* Development mode:
-------------------
If you are attempting to run the score server in an offline enviorment you 
will need to alter the following lines in `app/views/layouts/application.html.erb`
 
Remove the following line:
```ruby
  <%= debug(params) if Rails.env.development? %>
```
