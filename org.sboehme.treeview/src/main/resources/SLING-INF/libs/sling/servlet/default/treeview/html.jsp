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

<script type="text/javascript">
var currentNodePath = $.URLDecode("${resource.path}");
var paths = currentNodePath.substring(1).split("/");

</script>

</head>
<body>
<ul class="tree">
	<li class="last">Root
		<ul>
			<li class="default">
				<div></div>Animals
				<ul>
					<li class="default">
						<div></div>Birds
					</li>
					<li class="last">Mammals
						<ul>
							<li class="default">
								<div></div>Elephant
							</li>
							<li class="last">Mouse</li>
						</ul>
					</li>
				</ul>
			</li>
			<li class="last">Plants
				<ul>
					<li class="default">
						<div></div>Flowers
						<ul>
							<li class="default">
								<div></div>Rose
							</li>
							<li class="last">Tulip</li>
						</ul></li>
					<li class="last">Trees
					</li>
				</ul>
			</li>
		</ul>
	</li>
</ul>
</body>
</html>
