// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

$(document).on("page:load ready", function(){
    $("#deal_start_date").datepicker({ dateFormat: 'dd-mm-yy' });
    $("#deal_end_date").datepicker({ dateFormat: 'dd-mm-yy' });
    $("#advertisement_start_date").datepicker({ dateFormat: 'dd-mm-yy' });
    $("#advertisement_end_date").datepicker({ dateFormat: 'dd-mm-yy' });
    $("#service_preference_start_date").datepicker({ dateFormat: 'dd-mm-yy' });
    $("#service_preference_end_date").datepicker({ dateFormat: 'dd-mm-yy' });
});


function populate_service_provider(obj)
{
    if (obj.value != '')
	{
		var handleResponse = function (status, response) {
		   	var data=JSON.parse(response);
		   	var selectList = document.getElementById("deal_service_provider_id");
		   	selectList.options.length = 0;
		   	for(var i=0;i<data.length;i++){
				var option = document.createElement("option");
   				option.value = data[i].id;
    			option.text = data[i].name;
    			selectList.appendChild(option);
			}
		   	
		}
		var handleStateChange = function () {
		   switch (xmlhttp.readyState) {
		      case 0 : // UNINITIALIZED
		      case 1 : // LOADING
		      case 2 : // LOADED
		      case 3 : // INTERACTIVE
		      break;
		      case 4 : // COMPLETED
		      handleResponse(xmlhttp.status, xmlhttp.responseText);
		      break;
		      default: alert("error");
		   }
		}
		var xmlhttp=new XMLHttpRequest();
		xmlhttp.onreadystatechange=handleStateChange;
		xmlhttp.open("GET", "/deals/get_service_providers/?category="+obj.value,true);
		xmlhttp.send(null);
		
	}

}