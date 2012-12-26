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

<link href='http://fonts.googleapis.com/css?family=Michroma' rel='stylesheet' type='text/css'>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/jquery.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/bootstrap.min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/jquery-ui.custom.min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/jquery.cookie.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/jquery.hotkeys.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/jquery.jstree.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/jquery.scrollTo-min.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/jcrbrowser/js/urlEncode.js"></script>

<!-- <link rel="stylesheet" type="text/css" href="jquery/css/custom-theme/jquery-ui-1.8.16.custom.css"> -->
<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/jcrbrowser/css/style.css">
<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/jcrbrowser/css/bootstrap.css">
<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/jcrbrowser/css/theme/smoothness/jquery-ui.custom.css">

<!--[if IE]>
	<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/jcrbrowser/css/browser_ie.css"/>
<![endif]-->
<script type="text/javascript">
var currentNodePath = $.URLDecode("${resource.path}");
var paths = currentNodePath.substring(1).split("/");
var selectingNodeWhileOpeningTree=true;

//!"#$%&'()*+,./:;<=>?@[\]^`{|}~
var specialSelectorChars = new RegExp("[\\[\\]:!\"#\\$%&'\\(\\)\\*\\+,\\./:;<=>\\?@\\\\\\^`{}\\|~]","g");

function getPathFromLi(li){
	return $(li).parentsUntil(".root").andSelf().map(
			function() {
				return this.tagName == "LI"
						? $(this).attr("nodename") 
						: null;
			}
		).get().join("/");
};

function getSelectorFromPath(path){
	var paths = path.substring(1).split("/");
	return "#tree > ul [nodename='"+paths.join("'] > ul > [nodename='")+"']";
}

function openElement(root, paths) {
	var pathElementName = paths.shift().replace(specialSelectorChars,"\\\\$&");;
	var pathElementLi = root.children("[nodename='"+pathElementName+"']");
	if (pathElementLi.length === 0){
		alert("Couldn't find "+pathElementName+" under the path "+getPathFromLi(root.parent()));
	} else {
		selectingNodeWhileOpeningTree=true;
		$.jstree._reference(pathElementLi).select_node(pathElementLi, true);
		selectingNodeWhileOpeningTree=false;
		$.jstree._reference(pathElementLi).open_node(pathElementLi,
				function(){
					if (paths.length>0){
						openElement(pathElementLi.children("ul"), paths);
					}
				},
				function(){
					alert("Couldn't open "+pathElementName+" under the path "+getPathFromLi(root.parent()));
				}
			);

	}
}

function get_uri_from_li(li, extension){
	var path = getPathFromLi(li);
	path = $.URLEncode(path);
	path = path.replace(/%2F/g, "/");
	path = path.replace(/%3A/g, ":");
	return "<%= request.getContextPath() %>"+path+extension;
}

function adjust_height(){
	var header_height = $("#header").outerHeight(true);
	var alert_height = $("#alert").outerHeight(true);
	var footer_height = $("#footer").outerHeight(true);
	var sidebar_margin = $("#sidebar").outerHeight(true)-$("#sidebar").outerHeight(false);
	var usable_height = $(window).height() - header_height - alert_height - sidebar_margin - 1;
// activate again if the footer is needed	
// 	var usable_height = $(window).height() - header_height - footer_height - sidebar_margin - 1;
	$("#sidebar").height( usable_height );
	$("#outer_content").height( usable_height );
}

function isModifierPressed(e){
	return (e.shiftKey || e.altKey || e.ctrlKey);
}

$(document).ready(function() {
	adjust_height();
	$(window).resize( function() {
		adjust_height();
	});
	var selectorFromCurrentPath = getSelectorFromPath(currentNodePath);
	var scrollToPathFinished=false;
	// TO CREATE AN INSTANCE
	// select the tree container using jQuery
	$("#tree")
	.bind("loaded.jstree", function (event, data) {
		if (currentNodePath != "/") {
			openElement($("#tree > ul > li[nodename=''] > ul"), paths);
		}
		selectingNodeWhileOpeningTree=false;

	})
	// call `.jstree` with the options object
	.jstree({
		"core"      : {
			html_titles : false
		},
		"hotkeys"	: {
// 			"space" : function () { alert("hotkey pressed"); }
		},
		"html_data" : {
			"async" : true,
			"ajax" : {
				"url" : function (li) {
					// the li the user clicked on.
					return li.attr ?  get_uri_from_li(li,".jcrbrowser.nodes.html") : "<%= request.getContextPath() %>/.jcrbrowser.nodes.html"; }
			},
			"progressive_render" : true
		},
		// the `plugins` array allows you to configure the active plugins on this instance
		"plugins" : [ "themes", "html_data",  "ui", "core", "hotkeys", "crrm"]
    }).bind("rename.jstree", function (e, data) {
    	var newName = data.rslt.new_name;
    	$.ajax({
      	  type: 'POST',
			  url: $(data.rslt.obj).children("a:first").attr("target"),
      	  success: function(data) {
        		var target = "<%= request.getContextPath() %>/"+newName;
            	location.href=target+".jcrbrowser.view.html";
    		  },
      	  error: function(data) {
        		console.log("Error renaming node. Result:");
          		console.log(data);
    		    alert('Could not rename.');
    		  },
      	  data: { 
      		":operation": "move",
      		":dest": "/"+newName,
      	  	":transient_operation": "true" 
      		  }
      	});
    }).bind("remove.jstree", function (e, data) {
		var currentPath = $(data.rslt.obj).children("a:first").attr("target");
    	$.ajax({
        	  type: 'POST',
			  url: currentPath,
        	  success: function(data) {
          		console.log("Successful");
          		var target = getPathFromLi(data.rslt.obj.parents("li").first())
            	location.href=target+".jcrbrowser.view.html";
      		  },
        	  error: function(data) {
        		var errorDiv = $('<div id="alertMsg" class="alert alert-error">');
				errorDiv.append('<button type="button" class="close" data-dismiss="alert">&times;</button>');
				errorDiv.append("<h4>Error</h4>");
				var errorMessage = $("#Message",data.responseText);
				errorDiv.append(errorMessage);
				$("#alert").append(errorDiv);
				$('#alertMsg').bind('closed', function () {
					// All characters from the beginning to the last slash.
					// The slash is quoted with a backslash.
					var parentPathRegExp = /(^.*)\//g;
					var parentPath = parentPathRegExp.exec(currentPath)[1];
	            	location.href=parentPath+".jcrbrowser.view.html";
// 					$('#alertMsg').remove();
				});
				$("#alert").slideToggle(function() {
					adjust_height();
				  });
      		  },
        	  data: { 
        		  ":operation": "delete",
            	  ":transient_operation": "true" 
        	  }
        	});
    })
    .click(function(e) {		
        e.preventDefault(); 
       	var target = ($(e.target).attr("target")) ? $(e.target).attr("target") : $(e.target).parent().attr("target");
    	if (target && !selectingNodeWhileOpeningTree && !isModifierPressed(e)){
        	location.href=target+".jcrbrowser.view.html";
		}
	});
	
});
</script>	

</head>
<body>
	<div id="container-fluid">
		<div class="row-fluid">
			<div class="span12">
				 <div id="header" class="plate">
				 	<div class="logo">
					JCRBrowser 2.0
					</div> 
					<div>
					    <c:set var="authorized" value='<%=!"anonymous".equals(((HttpServletRequest)pageContext.getRequest()).getUserPrincipal().getName()) %>'/>
			            <c:if test='${!authorized}'>
			                <form action="/j_security_check" method="post">
			                        <input type="hidden" value="${pageContext.request.requestURI}" name="resource" />
			                        <label for="j_username">Username:</label>&nbsp;<input type="text" name="j_username" />
			                        <label for="j_password">Password:</label>&nbsp;<input type="password" name="j_password" />
			                        <input type="hidden" value="form" name="selectedAuthType" />
			                        <input type="submit" value="Login" >
			                </form>
			             </c:if>
			             <c:if test='${authorized}'>
			                    <%= request.getContextPath() %> User: "${pageContext.request.userPrincipal.name}" <a href="/system/sling/logout.html?resource=${pageContext.request.requestURI}">Logout</a>
			             </c:if>
					</div>
				</div> 
			</div>
		</div>
		<div id="alert" style="display:none;" class="row-fluid"></div>
		<div class="row-fluid">
			<div class="span4">
				<div id="sidebar" class="plate">
					<div id="tree" class="demo root" ></div>
				</div>
			</div>
			<div class="span8">
				<div id="outer_content" class="plate">
					<div id="inner_content_margin">
						<form action="not_configured_yet.change.properties" method="post">
							<c:set var="resourceIsNode" scope="request" value="<%=resource.adaptTo(Node.class) !=null %>"/>
							<c:if test="${resourceIsNode}">
								<%--
								For some reason I get the following exception when using the JSTL expression '${currentNode.properties}'
								instead of the scriptlet code 'currentNode.getProperties()':
								org.apache.sling.scripting.jsp.jasper.JasperException: Unable to compile class for JSP: 
								org.apache.sling.scripting.jsp.jasper.el.JspValueExpression cannot be resolved to a type
								see https://issues.apache.org/jira/browse/SLING-2455
								 --%>
								<c:forEach var="property" items="<%=currentNode.getProperties()%>">
							<%  Property property = (Property) pageContext.getAttribute("property");%>
									<fieldset>
										<label class="proplabel" for='${property.name}'>${property.name} [<%=PropertyType.nameFromValue(property.getType()) %>${property.multiple ? ' multiple' : ''}]</label>
										<c:choose>
										     <c:when test="${property.multiple}" >
										     	<fieldset class="propmultival_fieldset">
										     		<div>&nbsp;</div>
										     	<c:forEach var="value" items="<%=property.getValues() %>">
										     		<c:choose>
										     		<c:when test="${property.type == PropertyType.BINARY}" >
												     	<p>I'm a binary property</p>
												     </c:when>
												     <c:otherwise>
											     		<input class="propinputmultival" value="${value.string}"/>
												     </c:otherwise>
												     </c:choose>
										     	</c:forEach>
				     							</fieldset>
										     </c:when>
										     <c:when test="${false}" >
										     </c:when>
										     <c:otherwise>
											     <c:choose>
											     <c:when test="<%=property.getType() == PropertyType.BINARY %>" >
											     	<c:choose>
												     	<c:when test='<%=currentNode.getParent().isNodeType("nt:file") %>'>
												     		<a class="propinput" href="<%= request.getContextPath() %>${resource.parent.path}">Download</a>
												     	</c:when>
												     	<c:otherwise>
												     		<a class="propinput" href="<%= request.getContextPath() %>${resource.path}.property.download?property=${property.name}">View (choose "Save as..." to download)</a>
												     	</c:otherwise>
											     	</c:choose>
											     </c:when>
											     <c:otherwise>
													<input class="propinput" id="${property.name}" name="${property.name}" value="${property.string}"/>							
											     </c:otherwise>
											     </c:choose>
										     </c:otherwise>
										 </c:choose>
									</fieldset>
								</c:forEach>
							</c:if>
						</form>
					</div>
			    </div>
			</div>
	    </div>
		<div class="row-fluid" style="display:none">
			<div class="span12">
				 <div id="footer" class="plate">
						<p>I'm looking forward to be filled with useful content</p>
				</div>
			</div>
		</div>
	</div>
</div>	
</body>
</html>
