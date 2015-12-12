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
//= require turbolinks
//= require_tree .
//= require bootstrap-switch
//= require moment
//= require bootstrap-datetimepicker
//= require c3
//= require d3
var mouseover = false;

$(document).ready(function() {

	if( $("div.alert") ) {

		$("div.alert")
			.mouseover(function() {
				mouseover = true;
			})
			.mouseout(function() {
				mouseover = false;
			});
	}
	
	setTimeout(checkAlert, 2000);
});

function checkAlert() {
	if ( mouseover == false ) {
		$().alert('close');
		$("div.alert").fadeTo(500, 0).slideUp(500, function(){
			$("div.alert").remove();
		});
	}
	
	if( $("div.alert") ) {
		setTimeout(checkAlert, 2000);
	}
}

