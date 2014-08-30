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
org.sboehme.jcrbrowser.TreeController = (function() {

	function TreeController(settings, mainController){
		var thatTreeController = this;
		this.settings = settings;
		this.mainController = mainController;
		
		$(document).ready(function() {
			$("#tree").on("click", "li.jstree-node>a.jstree-anchor>i.open-icon",function(e, data) {
				thatTreeController.openNodeTarget(e);
			});
	
			$("#tree").on("dblclick", "li.jstree-node>a.jstree-anchor",function(e, data) {
				var id = $(e.target).parents("li:first").attr("id");
				thatTreeController.openRenameNodeDialog(id);
			});
		});
	};

	TreeController.prototype.openNodeTarget = function(e) {
		var url = $(e.target).parent().attr("target");
		url = this.mainController.decodeFromHTML(url);
		url = this.mainController.encodeURL(url);
		location.href=url+".jcrbrowser.html";
	}

	TreeController.prototype.openRenameNodeDialog = function(id) {
		var liElement = $('#'+id);
		$("#tree").jstree("edit", $('#'+id), liElement.attr("nodename"));
	}
	
	TreeController.prototype.renameNode = function(e, data) {
		var thatTreeController = this;
		var newName = data.text;
		var oldName = data.old;
		if (oldName!==newName){
			var encodedTargetURI = this.mainController.decodeFromHTML(data.node.a_attr.target);
			var newURI = encodedTargetURI.replace(oldName, newName);
			var url = data.node.a_attr.target;
			url = this.mainController.decodeFromHTML(url);
			url = this.mainController.encodeURL(url);
			$.ajax({
		  	  type: 'POST',
				  url: url,
		  	  success: function(server_data) {
		  		  var newURIencoded = thatTreeController.mainController.encodeURL(newURI);
		    	  var target = thatTreeController.settings.contextPath+newURIencoded;
		    	  location.href=target+".jcrbrowser.html";
			  },
		  	  error: function(server_data) {
		  		  thatTreeController.mainController.displayAlert(server_data.responseText, data.rlbk);
			  },
			  contentType : 'application/x-www-form-urlencoded; charset=UTF-8',
		  	  data: { 
		  		":operation": "move",
		  		"_charset_": "utf-8",
		  		":dest": newURI
		  		  }
		  	});
		}
	}
	
	TreeController.prototype.getSelectorFromPath = function(path){
		var paths = path.substring(1).split("/");
		return "#tree > ul [nodename='"+paths.join("'] > ul > [nodename='")+"']";
	}

	TreeController.prototype.getPathFromLi = function(li){
		return $(li).parentsUntil(".root").andSelf().map(
				function() {
					return this.tagName == "LI"
							? $(this).attr("nodename") 
							: null;
				}
			).get().join("/");
	};

	TreeController.prototype.openElement = function(root, paths) {
		var thisTreeController = this;
		var pathElementName = paths.shift();//.replace(specialSelectorChars,"\\\\$&");
		var pathElementLi = root.children("[nodename='"+pathElementName+"']");
		if (pathElementLi.length === 0){
			alert("Couldn't find "+pathElementName+" under the path "+this.getPathFromLi(root.parent()));
		} else {
			$('#tree').jstree('open_node', pathElementLi,
					function(){
						if (paths.length>0){
							thisTreeController.openElement($("#"+pathElementLi.attr('id')).children("ul"), paths);
						} else  {
							selectingNodeWhileOpeningTree=true;
							$('#tree').jstree('select_node', pathElementLi.attr('id'), 'true'/*doesn't seem to work*/);
							selectingNodeWhileOpeningTree=false;
					        var target = $('#'+pathElementLi.attr('id')+' a:first');
					        target.focus();
					        console.log('#'+pathElementLi.attr('id')+' a:first');
						}
					}
				);
		}
	}

	TreeController.prototype.get_uri_from_li = function(li, extension){
		var path = this.getPathFromLi(li);
		path = this.mainController.encodeURL(path);
		path = path.replace(/%2F/g, "/");
		path = path.replace(/%3A/g, ":");
		return this.settings.contextPath+path+extension;
	}
	/*
	function isModifierPressed(e){
		return (e.shiftKey || e.altKey || e.ctrlKey);
	}
	*/

	return TreeController;
}());
