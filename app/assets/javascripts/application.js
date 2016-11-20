// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-notify
//= require turbolinks
//= require_tree .
//= require bootstrap-switch
//= require moment
//= require bootstrap-datetimepicker
//= require c3
//= require d3

(function() {
  var init_bootstrap_modules = function() {
    $(".bootstrap-switches").bootstrapSwitch();
    $('[data-toggle="tooltip"]').tooltip(); 
  };

  $(document).on('turbolinks:load', init_bootstrap_modules);

}).call(this);
