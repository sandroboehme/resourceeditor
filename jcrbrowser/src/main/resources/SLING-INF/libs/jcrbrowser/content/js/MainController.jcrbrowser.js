/*
* Copyright 2014 Sandro Boehme
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*   http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// creating the namespace
var org = org || {};
org.sboehme = org.sboehme || {};
org.sboehme.jcrbrowser = org.sboehme.jcrbrowser || {};


/*
 Controller - It adapts the JSTree library for the use in the JCRBrowser.
 This JCRBrowserJSTreeAdapter contains as less logic as needed to configure the JSTree for the JCRBrowser. For 
 everything that goes beyond that and contains more functionality, the JCRBrowserTreeController is called.
*/

//defining the module
org.sboehme.jcrbrowser.MainController = (function() {

	function MainController(settings, ntManager){
		this.ntManager = ntManager;
		
		var thisMainController = this;
		
		$(document).ready(function() {
			$('#alertClose').click(function () {
				$("#alert").slideUp(function() {
					thisMainController.adjust_height();
				});
			})
		});
	};

	MainController.prototype.encodeToHTML = function(unencodedHTML){
		//create a in-memory div, set it's inner text(which jQuery automatically encodes)
		//then grab the encoded contents back out.The div never exists on the page.
		return $('<div/>').text(unencodedHTML).html();
	}

	MainController.prototype.decodeFromHTML = function(encodedHTML){
		return $("<div/>").html(encodedHTML).text();
	}
	
	
	MainController.prototype.adjust_height = function(objectId){
		var login_height = $("#login").outerHeight(true);
		var header_height = $("#header").outerHeight(true);
		var alert_height = $("#alerts").outerHeight(true);
		var footer_height = $("#footer").outerHeight(true);
		var sidebar_margin = $("#sidebar").outerHeight(true)-$("#sidebar").outerHeight(false);
		var usable_height = $(window).height() - login_height - header_height - alert_height - sidebar_margin - 1;
		
	// activate again if the footer is needed	
//	 	var usable_height = $(window).height() - header_height - footer_height - sidebar_margin - 1;
		$("#sidebar").height( usable_height );
		$("#outer_content").height( usable_height );
	}

	MainController.prototype.displayAlert = function(errorMsg, rlbk){
		var thisMainController = this;
		$('#alertMsg #Message').remove();
		// Let jQuery parse the error message from the html 
		// by using an id selector.
		var errorMessage = $("#Message",errorMsg).html();
		$('#alertMsg').append($("<div id='Message'>").append(errorMessage));
		$("#alert").slideDown(function() {
			thisMainController.adjust_height();
		});
		$.jstree.rollback(rlbk);
	}


	MainController.prototype.getNTFromLi = function(li){
		var nt_name = $(li).children("a").find("span span.node-type").text();
	    return this.ntManager.getNodeType(nt_name);	
	}
	
	return MainController;
}());
