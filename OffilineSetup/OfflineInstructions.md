Offline Setup Instructions
==========================

If you are attempting to run the score server in an offline enviorment you 
will need to alter the following lines in `app/views/layouts/application.html.erb`
 
Remove the following line:
```ruby
  <%= debug(params) if Rails.env.development? %>
```
