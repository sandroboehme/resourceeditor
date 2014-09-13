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
org.sboehme.jcrbrowser.tree = org.sboehme.jcrbrowser.tree || {};


/*
 JSTreeAdapter - It adapts the JSTree library for the use in the JCRBrowser.
 This JSTreeAdapter contains as less logic as needed to configure the JSTree for the JCRBrowser. For 
 everything that goes beyond that and contains more functionality, the other JCRBrowser controllers are called.
*/

//defining the module
org.sboehme.jcrbrowser.tree.JSTreeAdapter = (function() {

	function JSTreeAdapter(settings, treeController, mainController){
		this.settings = settings;
		this.treeController = treeController;
		this.mainController = mainController;
		
var currentNodePath = decodeURI(settings.resourcePath);
var paths = currentNodePath.substring(1).split("/");
var selectingNodeWhileOpeningTree=true;

var thisJSTreeAdapter = this;

$(document).ready(function() {
	$(window).resize( function() {
		thisJSTreeAdapter.mainController.adjust_height();
	});
	
	var selectorFromCurrentPath = treeController.getSelectorFromPath(currentNodePath);
	
	var scrollToPathFinished=false;
	
	thisJSTreeAdapter.mainController.adjust_height();
	
	
	// TO CREATE AN INSTANCE
	// select the tree container using jQuery
	$("#tree")
	.bind("loaded.jstree", function (event, data) {
		if (currentNodePath != "/") {
			treeController.openElement($("#tree > ul > li[nodename=''] > ul"), paths);
		}
		selectingNodeWhileOpeningTree=false;
	})
	// call `.jstree` with the options object
	.jstree({
		"core"      : {
		    "check_callback" : true,
		    multiple: true,
			html_titles : false,
			animation: 600,
			'data' : {
				'url' : function (liJson) {
					// initial call for the root element
					if (liJson.id === '#'){
						return settings.contextPath+"/.jcrbrowser.rootnodes.json";
					} else {
						// the li the user clicked on.
						var li = $('#'+liJson.id);
						return treeController.get_uri_from_li(li,".jcrbrowser.nodes.json");
					}
				},
			    'data' : function (node) {
			        return { 'id' : node.id };
			      }
			}
		},
		"ui"      : {
			"select_limit" : 2
		},
		"crrm"      : {
			"move" : {
				"always_copy" : false,
		        "check_move"  : function (m) {
			        // you find the member description here
			        // http://www.jstree.com/documentation/core.html#_get_move
			        var src_li = m.o;
			        var src_nt = mainController.getNTFromLi(src_li);
			        var src_nodename = src_li.attr("nodename");
			        
			        var new_parent_ul = m.np.children("ul");
			        var calculated_position = m.cp;
			        var liAlreadySelected = new_parent_ul.length==0 && m.np.prop("tagName").toUpperCase() == 'LI';
			        var dest_li = liAlreadySelected ? m.np : new_parent_ul.children("li:eq("+(calculated_position-1)+")");
			        var dest_nt = mainController.getNTFromLi(dest_li);
					var result;
					if (dest_nt != null){ 
						result = dest_nt.canAddChildNode(src_nodename, src_nt);
					}
                    return result;
                  }
			}
		},
		"dnd" : {
			"drop_finish" : function () {
				console.log("drop");
				alert("DROP"); 
			},
			"drag_finish" : function (data) {
				console.log("drag");
				alert("DRAG OK"); 
			}
		},
		"hotkeys"	: {
// 			"space" : function () { alert("hotkey pressed"); }
		},
		// the `plugins` array allows you to configure the active plugins on this instance
		"plugins" : [ "themes", "ui", "core", "hotkeys", "crrm", "dnd"]
    }).bind("rename_node.jstree", function (e, data) {
    	treeController.renameNode(e, data);
    }).bind("move_node.jstree", function (e, data) {
    	// see http://www.jstree.com/documentation/core ._get_move()
    	var src_li = data.rslt.o;
    	var src_path = ""+settings.contextPath+src_li.children("a").attr("target");
    	var dest_li = data.rslt.np; // new parent .cr - same as np, but if a root node is created this is -1
    	var dest_li_path = dest_li.children("a").attr("target") == "/" ? "" : dest_li.children("a").attr("target");
    	var dest_path = ""+settings.contextPath+dest_li_path+"/"+src_li.attr("nodename");
    	var original_parent = data.rslt.op;
    	var is_copy = data.rslt.cy;
    	var position = data.rslt.cp;
    	$.ajax({
      	  type: 'POST',
			  url: src_path,
      	  success: function(server_data) {
        		var target = ""+settings.contextPath+dest_path;
            	location.href=target+".jcrbrowser.html";
    		  },
      	  error: function(server_data) {
      			displayAlert(server_data.responseText, data.rlbk);
    		  },
      	  data: { 
       		":operation": "move",
//          	":order": position,
      		":dest": dest_path
      		  }
      	});
    }).on('hover_node.jstree', function (event, nodeObj) {
        $('#'+nodeObj.node.id+' a:first').focus();
    }).on('select_node.jstree', function (e, data) {
    	;
    }).bind("delete_node.jstree", function (e, data) {
    	//http://www.jstree.com/api/#/?q=delete&f=delete_node.jstree
		var currentPath = $(data.rslt.obj).children("a:first").attr("target");
		var parentPath = data.rslt.parent.children("a:first").attr("target");
		var confirmationMsg = "You are about to delete "+currentPath+" and all its sub nodes. Are you sure?";
		bootbox.confirm(confirmationMsg, function(result) {
			if (result){
		    	$.ajax({
		        	  type: 'POST',
					  url: currentPath,
		        	  success: function(server_data) {
		            	location.href=parentPath+".jcrbrowser.html";
		      		  },
		        	  error: function(server_data) {
		        		displayAlert(server_data.responseText, data.rlbk);
		      		  },
		        	  data: { 
		        		  ":operation": "delete"
		        	  }
		        	});
			} else {
        		$.jstree.rollback(data.rlbk);
			}
		});
	});
});

	};
	return JSTreeAdapter;
}());
