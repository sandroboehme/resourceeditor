<!DOCTYPE html>
<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ page import="java.security.Principal"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<sling:defineObjects />

<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<script type="text/javascript" src="<%= request.getContextPath() %>/libs/jcrbrowser/content/js/jquery.min.js"></script>

<script type="text/javascript">
	function writeNewText(){
		$.ajax({
			type: "PUT",
			url: "/libs/sling/servlet/default/jcrbrowser/dhtml.jsp",
			success: function( data ) {
				alert("text "+data);
				// refresh the page
				window.location.href=window.location.href;
			},
			dataType: "text"
			});
	}
</script>

</head>
<body>
	<input onclick="writeNewText();" type="button" value="Write new text!">
	<div>Some other text.</div>
	<div id="new-text-id"></div>
</body>
</html>
