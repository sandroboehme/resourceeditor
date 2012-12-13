<!DOCTYPE html>
<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>
<sling:defineObjects />
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/libs/org/sboehme/treeview/css/style.css">


<script type="text/javascript" src="<%= request.getContextPath() %>/libs/test/org/sboehme/treeview/jquery/jquery-1.8.2.min.js"></script>
<%-- <script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/jquery.scrollTo-min.js"></script> --%>
<script type="text/javascript" src="http://demos.flesler.com/jquery/scrollTo/js/jquery.scrollTo-min.js"></script>

<script type="text/javascript">


function getPathFromLi(li){
	return $(li).parentsUntil(".root").andSelf().map(
			function() {
				return this.tagName == "LI"
						? $(this).attr("nodename") 
						: null;
			}
		).get().join("/");
};


  $.fn.scrollTo = function() {

    var cTop = this.offset().top;
    var cHeight = this.outerHeight(true);
    var windowTop = $(window).scrollTop();
    var visibleHeight = $(window).height();

    if (cTop < windowTop) {
      $(jQuery.browser.webkit ? "body": "html")
        .stop().animate({'scrollTop': cTop}, 'slow', 'swing');
    } else if (cTop + cHeight > windowTop + visibleHeight) {
      $(jQuery.browser.webkit ? "body": "html")
        .stop().animate({'scrollTop': cTop - visibleHeight + cHeight}, 'fast');
    }
  };


$.fn.treeview = function(options){

	var LEFT = 37;
	var UP = 38;
	var RIGHT = 39;
	var DOWN = 40;
	var loadingChilds=false;
	
	options = $.extend({
		hintergrund: "#000000"
	}, options);
	
	var treeElement = $(this);
	
	start();

	function start(){
		load(treeElement);
		treeElement.children("ul li div:first").addClass('selected');
	}

	treeElement.attr('tabindex','0');
	
	function nextLiBelow(li){
		if (li.hasClass("root")) {
			return li.children("ul").children("li").children("ul").children("li:last");
		}
		if(li.next().length == 0){
			return nextLiBelow(li.parent().parent());
		} else {
			return li.next();
		}
	}
	
	/*
	rechts gedrückt lassen öffnet alles
	links gedrückt lassen schließt alles
	*/
	
	treeElement.bind('keydown', function(event) {
  		event.stopImmediatePropagation();
  		event.preventDefault();
	  // the selected <div/>
	  var selected = $('.selected:first');
	  if ( ! loadingChilds) {
	  	selected.removeClass('selected');
	  }
	  var li = selected.parent();
	  var parent = li
	  	.parent()
	  	.parent()
	  	.children("div:first");
	  var firstChild = li
  			.children("ul")
	  		.children("li:first")
	  		.children("div:first");
	  var hasChildren = li
	  		.children("ul")
	  		.children("li")
	  		.length > 0;
	  var isOpen = li.hasClass("open");
	  
  	  if (event.which === DOWN) {
  		  if (hasChildren) {
  			firstChild
  		  		.addClass("selected");
  		  } else {
  			var isLast = li.next().length == 0;
  			if (isLast) {
  				nextLiBelow(li)
  					.children("div:first")
  					.addClass("selected");
  			} else {
	  			li
	  	            .next()
	  	            .children('div:first')
	  	            .addClass('selected');
  			}
  		  }
  	    } else if (event.which === UP) {
    		  var hasPrevChilds = li
    		  		.prev()
		  	  		.children("ul")
		  	  		.children("li")
		  	  		.length > 0;
    		  var isFirst = li.prev().length == 0;
    		  if (isFirst){
    			  if (li.parent().parent().hasClass("root")){
    				li
  						.children("div:first")
			  			.addClass("selected");  
    			  } else {
    			  	li
				  		.parent()
				  		.parent()
	  					.children("div:first")
    			  		.addClass("selected");  
    			  }
    		  } else if (hasPrevChilds){
	    		  li
	  		  		.prev()
		  	  		.children("ul")
		  	  		.children("li:last")
  					.children("div:first")
 	        	    .addClass('selected');
    		  } else {
	    		  li
   		            .prev()
   	    	        .children('div:first')
   	        	    .addClass('selected');
    		  }
      	} else if (event.which === RIGHT) {
      	  if (hasChildren){
  			firstChild
  		  		.addClass("selected");
      	  } else if (isOpen){
				nextLiBelow(li)
					.children("div:first")
					.addClass("selected");
      	  } else if ( ! loadingChilds){
      		loadingChilds = true;
    	  	load(jQuery(selected).parent());
  	      	selected.addClass('selected');
  	      	li.removeClass('closed');
  	      	li.addClass('open');
      	  }
	  	} else if (event.which === LEFT) {
	  	  var children = li.children("ul");
	  	  if (isOpen){
		  	li
		  		.children("ul")
		  		.remove();
		  	li
				.children("div:first")
				.addClass("selected");
  	      	li.removeClass('open');
  	      	li.addClass('closed');
	  	  } else {
			  parent
			  	.addClass("selected");  
	  	  }
		}
  		$(".selected").scrollTo();
    });
	
	function load(li){
		$.ajax({
		      type: "GET",
		      dataType: "json",
			  url: options.url(li),
			  success: function(data) {
				  li.append(renderNodes(data));
				  loadingChilds=false;
			  },
			  error: function(data) {
				  loadingChilds=false;
			      alert('Load was performed but an error occured: '+data);
			  }
			});
	}
	
	function renderNodes(jsonContent) {
	    var index, ul;

	    // Create a list for these contents
	    ul = $('<ul style="display: none;">');

	    // Fill it in
	    $.each(jsonContent, function(index, entry) {
	      var li, div;

	      var hasChildren = entry.children;
	      // Create list item
	      li = $('<li>').attr('class', (hasChildren ? 'open' : 'closed'));

    	  $.each(entry.attr, function(k, v) {
	    	  li.attr(k, v);
    	  });
    	  li.attr("id", entry.attr['nodename']);
	      
	      // Set the text
	      div = $('<div class="node"><a href="#">'+entry.data.title+'</a></div>');
	      li.append(div);

// 	  	  console.log(entry);
	  	
	      // Append a sublist of its contents if it has them
	      if (hasChildren) {
	        li.append(renderNodes(entry.children));
	      }
	      
	      li.bind('click', function(event) {
	    	  event.stopPropagation();
	    	  $('.selected').removeClass('selected');
	    	  $(this).children('div:first').addClass('selected');
	      });

	      // Add this item to our list
	      ul.append(li);
	    });

	    ul.stop().slideToggle('slow');
	    
	    // Return it
	    return ul;
	  }
}

$(document).ready(function() {
	// Plugin-Aufruf
	$("#dynamic_tree")
	// call the treeview plugin with the options object
	.treeview({
		"url" : function (li) {
			// the li the user clicked on.
			var pathFromLi = (li == null) ? "/" : getPathFromLi(li)+"/";
			return "<%= request.getContextPath() %>"+pathFromLi+".treeviewtest.nodes.json"; 
		}
	}) // call of the tree view plugin
	
}); // document ready
</script>

<style type="text/css">
body {
	background-color: #505050;
	color: #c0c0c0;
}
</style>

</head>
<body>

<div id="dynamic_tree" class="tree root"></div>

<div style="padding: 10px 0;"/>

<div id="static_tree" class="tree">
	<ul>
		<li class="open"><div class="node">Root</div>
			<ul>
				<li class="open">
					<div class="node">Animals</div>
					<ul>
						<li class="closed">
							<div class="node">Birds</div>
						</li>
						<li class="open"><div class="node">Mammals</div>
							<ul>
								<li class="closed">
									<div class="node">Elephant</div>
								</li>
								<li class="closed"><div class="node">Mouse</div></li>
							</ul>
						</li>
					</ul>
				</li>
				<li class="open"><div class="node">Plants</div>
					<ul>
						<li class="open">
							<div class="node">Flowers</div>
							<ul>
								<li class="closed">
									<div class="node">Rose</div>
								</li>
								<li class="closed"><div class="node">Tulip</div></li>
							</ul></li>
						<li class="closed"><div class="node">Trees</div>
						</li>
					</ul>
				</li>
			</ul>
		</li>
	</ul>
</div>
</body>
</html>
