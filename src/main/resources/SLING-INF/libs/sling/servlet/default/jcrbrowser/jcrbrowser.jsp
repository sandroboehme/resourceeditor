<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>
<sling:defineObjects />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<!-- TODO servername and port should not be absolute -->
<script type="text/javascript" src="${request.contextPath}/jcrbrowser/js/jquery.js"></script>
<script type="text/javascript" src="${request.contextPath}/jcrbrowser/js/jquery.cookie.js"></script>
<script type="text/javascript" src="${request.contextPath}/jcrbrowser/js/jquery.hotkeys.js"></script>
<script type="text/javascript" src="${request.contextPath}/jcrbrowser/js/jquery.jstree.js"></script>
<script type="text/javascript" src="${request.contextPath}/jcrbrowser/js/jquery.scrollTo-min.js"></script>
<script type="text/javascript" src="${request.contextPath}/jcrbrowser/js/urlEncode.js"></script>
<!-- <script type="text/javascript" src="jquery/js/jquery-ui-1.8.16.custom.min.js"></script> -->
<!-- <script type="text/javascript" src="jquery/js/jquery-1.6.2.min.js"></script> -->

<!-- <link rel="stylesheet" type="text/css" href="jquery/css/custom-theme/jquery-ui-1.8.16.custom.css"> -->
<link rel="stylesheet" type="text/css" href="${request.contextPath}/jcrbrowser/css/browser.css">
<link rel="stylesheet" type="text/css" media="all" href="${request.contextPath}/jcrbrowser/css/style.css">
<script type="text/javascript">
var currentNodePath = $.URLDecode("${resource.path}");
var paths = currentNodePath.substring(1).split("/");

//!"#$%&'()*+,./:;<=>?@[\]^`{|}~
var specialSelectorChars = new RegExp("[\\[\\]:!\"#\\$%&'\\(\\)\\*\\+,\\./:;<=>\\?@\\\\\\^`{}\\|~]","g");

function getPathFromLi(li){
	return $(li).parentsUntil(".root").andSelf().map(
			function() {
				return this.tagName === 'LI'
						? $(this).attr("nodename").trim() 
						: null;
			}
		).get().join("/");
};

function getSelectorFromPath(path){
	var paths = path.substring(1).split("/");
	return "#tree > ul [nodename='"+paths.join("'] > ul > [nodename='")+"']";
}

function _openingPathFinished(){
	var selectorFromCurrentPath = getSelectorFromPath(currentNodePath);
	$("#inner_sidebar").scrollTo( $(selectorFromCurrentPath) ,800);
}

function openElement(root, paths) {
	var pathElementName = paths.shift().replace(specialSelectorChars,"\\\\$&");;
	var pathElementLi = root.children("[nodename='"+pathElementName+"']");
	if (pathElementLi.length === 0){
		alert("Couldn't find "+pathElementName+" under the path "+getPathFromLi(root.parent()));
	} else {
		$.jstree._reference(pathElementLi).select_node(pathElementLi, true);
		if (paths.length==0){
			_openingPathFinished();
		}
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
	return "${request.contextPath}/"+path+extension;
}

function adjust_height(){
	var header_height = $("#header").outerHeight(true);
	var footer_height = $("#footer").outerHeight(true);
	var sidebar_margin = $("#sidebar").outerHeight(true)-$("#sidebar").outerHeight(false);
	var content_container_height = $("#content_container").outerHeight(true);
	var usable_height = $(window).height() - header_height - footer_height - sidebar_margin - 1;
	$("#sidebar").height( usable_height );
	$("#outer_content").height( usable_height );
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
	})
	// call `.jstree` with the options object
	.jstree({
		"json_data" : {
			"async" : true,
			"ajax" : {
				"url" : function (li) {
					// the li the user clicked on.
					return li.attr ?  get_uri_from_li(li,".jcrbrowser.nodes.json") : "${request.contextPath}/.jcrbrowser.nodes.json"; },
			},
			"progressive_render" : true, 
		},
		"contextmenu" : {
			"items" : function(li){
							var menu = {"create_sibling_node" : {
											"label"	: "Create sibling node",
											"submenu"	: {}
								}
							};
							var the_nodetypes = "";
							$.ajax({
// 								  url: '${request.contextPath}/jcrbrowser/jcr%3Asystem.nodetypes.json',
							  url: get_uri_from_li(li,".nodetypes.json"),
							  dataType: 'json',
							  async: false,
							  success: function( data ) {
							    the_nodetypes=data;
							  }
							});
							$.each(the_nodetypes,function(){
								menu["create_sibling_node"]["submenu"][this] = {
										"label" : "Create "+this,
										"action": function(obj){alert(this+"");}
									};
							}
							);
							return menu;
// 							"create" : {
// 								// The item label
// 								"label"				: "Create",
// 								// The function to execute upon a click
// 								"action"			: function (obj) {
// // 									alert(obj.html());
// // 									$("#tree").jstree("create", obj, "after",
// // 											{ "data" : "child2" },
// // 									true);
// // 									obj.rename();
// // 									$("#tree").jstree("remove",obj); 
// // 									$("#tree").jstree("rename",obj);
// 									},
// 						},
// 						"create_sibling_node" : {
// 							"label"	: "Create sibling node",
// 							"submenu"	: {
// 								"ntunstructured" : {
// 									"label"	: "Create ntunstructured",
// 									"action"	: function (obj) {
// 										createNode(obj, "nt:unstructured");
// 									}
// 								}
// 							}
// 						}
					}	
		},
		// the `plugins` array allows you to configure the active plugins on this instance
		"plugins" : [ "themes", "json_data",  "ui", "core", "hotkeys"]
	// it makes sense to configure a plugin only if overriding the defaults
	})

});
</script>

</head>
<body>
	<div id="content_container">
		 <div id="header" class="plate">
			JCRBrowser 2.0
		</div>
		<div id="sidebar" class="plate">
			<div id="tree" class="demo root" ></div>
		</div>
		<div id="outer_content" class="plate">
			<div id="inner_content">
				<div id="inner_content_margin">
					<form action="not_configured_yet.change.properties" method="post">
						<c:set var="resourceIsNode" scope="request" value="<%=resource.adaptTo(Node.class) !=null %>"/>
						<c:if test="${resourceIsNode}">
							<%--
							For some reason I get the following exception when using the JSTL expression '${currentNode.properties}'
							instead of the scriptlet code 'currentNode.getProperties()':
							org.apache.sling.scripting.jsp.jasper.JasperException: Unable to compile class for JSP: 
							org.apache.sling.scripting.jsp.jasper.el.JspValueExpression cannot be resolved to a type
							 --%>
							<c:forEach var="property" items="<%=currentNode.getProperties()%>">
						<%  Property property = (Property) pageContext.getAttribute("property");%>
								<fieldset>
									<label class="proplabel" for='${property.name}'>${property.name} [<%=PropertyType.nameFromValue(property.getType()) %> ${property.multiple ? 'multiple' : ''}]</label>
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
											     		<a class="propinput" href="${resource.parent.path}">Download</a>
											     	</c:when>
											     	<c:otherwise>
											     		<a class="propinput" href="${resource.path}.property.download?property=${property.name}">View (choose "Save as..." to download)</a>
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
        <div class="clear"></div>
		 <div id="footer" class="plate">
				<p>I'm looking forward to be filled with useful content</p>
		</div>
	</div>
</div>	
</body>
</html>
