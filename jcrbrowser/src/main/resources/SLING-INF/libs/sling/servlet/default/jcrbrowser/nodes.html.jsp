<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.LinkedList, java.util.List"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>
<sling:defineObjects />
<% response.setContentType("text/html"); %>


	<%-- This condition block is specifically for the root node. --%>
	<c:if test='${"/" == resource.path}'>
		<li class="jstree-open" nodename="">
			<a href="JavaScript:void(0);" target="<%= request.getContextPath() %>/">/</a>
			<ul>
	</c:if>

	<c:forEach var="theResource" items="<%=resource.listChildren()%>" varStatus="status">
		<% 
		Resource theResource = (Resource) pageContext.getAttribute("theResource");
		Node node = theResource.adaptTo(Node.class);
		String modifiedAsterix = node !=null && node.isModified() ? "*" : "";
		String aPath = request.getContextPath() + theResource.getPath();
		// TODO Find out why e.g. '//apps/sling' has two slashes 
		String thePath = aPath.startsWith("//") ? aPath.substring(1) : aPath;
		%>
	
		<li class="jstree-closed" nodename="${theResource.name}">
			<a href="JavaScript:void(0);" target="<%= java.net.URLEncoder.encode(thePath, "UTF-8").replaceAll("%2F", "/").replaceAll("%3A", ":") %>">${theResource.name}<span><%=modifiedAsterix%> [${theResource.resourceType}]</span></a>
		</li>
	</c:forEach>

	<c:if test='${"/" == resource.path}'>
			</ul>
		</li>
	</c:if>