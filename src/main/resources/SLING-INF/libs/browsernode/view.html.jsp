<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>
<sling:defineObjects />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
Hello ${resource.path}! I have been rendered by the view script!
</body>
</html>