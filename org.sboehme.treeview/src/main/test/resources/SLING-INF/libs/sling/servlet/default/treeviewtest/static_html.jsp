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


<script type="text/javascript" src="<%= request.getContextPath() %>/libs/org/sboehme/treeview/jquery/jquery-1.8.2.min.js"></script>

<script type="text/javascript">

$.fn.tooltip = function(optionen){
	optionen = $.extend({
		hintergrund: "#000000"
	}, optionen);
	console.log(optionen.hintergrund);
	console.log($(this).attr("id"));
	console.log($(this));
	
	function zeigeTooltip(){
		$("<div>", {
			id: "tooltip",
			css: {
				background: optionen.hintergrund,
				color: "#444",
				display: "none"
			},
			html: "Beispieltext"
		})
		.appendTo("body")
		.fadeIn(1000);
	}
	$(this).bind({
		mouseenter: function(){
			zeigeTooltip();
		},
		mouseenter: function(){
			if ($("#tooltip").css("opacity") != 0) {
				$("#tooltip").stop().remove();
			}
				 
				zeigeTooltip();
		},
		mouseleave: function(){
			$("#tooltip").fadeOut(
				500,
				function(){
					$(this).remove();
				}
			);
		}
	});
	
}

$(document).ready(function() {
	// Plugin-Aufruf
	$("#tree").tooltip({
		hintergrund: "#CCCCCC"
	});
});
</script>

<style type="text/css">
body {
	background-color: #505050;
	color: #c0c0c0;
}
</style>

</head>
<body>
<ul id="tree" class="tree">
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
</body>
</html>
