// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require s3_file_field
//= require_tree .

var ready;

ready = function() {
  return $(".js-s3_file_field").each(function() {
    var $parent =  $(this).parent();
    return $(this).S3FileField({
      done: function(e, data) {
        return $parent.append("<span>" + data.result.url + "</span>");
      },
      fail: function(e, data) {
        return alert(data.failReason);
      },
      progress: function(e, data) {
        window.document.title = parseInt(data.loaded / data.total * 100, 10) + '%'
      }
    });
  });
};

$(document).ready(ready);

$(document).on('page:load', ready);
