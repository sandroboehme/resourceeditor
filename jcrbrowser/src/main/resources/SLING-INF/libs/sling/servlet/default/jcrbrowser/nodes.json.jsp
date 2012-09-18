<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.LinkedList, java.util.List"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>
<sling:defineObjects />
<% response.setContentType("application/json"); %>
		<%-- This condition block is specifically for the root node. --%>
		<c:if test='${"/" == resource.path}'>
[{
            	"data":	{
            			"title" : "/",
            			"attr" :{
            					"href" : "<%= request.getContextPath() %>/.jcrbrowser.view.html"
            					}
            			},
            		"state" : "open",
            		"attr" : { "nodename" : "" },
            		"children" :
		</c:if>
	[
			<c:forEach var="theResource" items="<%=resource.listChildren()%>" varStatus="status">
				<% 
				Resource theResource = (Resource) pageContext.getAttribute("theResource");
				String aPath = request.getContextPath() + theResource.getPath();
				// TODO Find out why e.g. '//apps/sling' has two slashes 
				String thePath = aPath.startsWith("//") ? aPath.substring(1) + ".jcrbrowser.view.html" : aPath + ".jcrbrowser.view.html";
				%>
		{
		"data":	{
				"title" : "${theResource.name} [${theResource.resourceType}]",
				"attr" :{
						"href" : "<%= java.net.URLEncoder.encode(thePath, "UTF-8").replaceAll("%2F", "/").replaceAll("%3A", ":") %>"
						}
				},
			<% if(theResource.listChildren().hasNext()){ %>
			"state" : "closed",
			<% } %>
			"attr" : {"nodename" : "${theResource.name}"}
		}${!status.last ? ',': ''}
			</c:forEach>
	]

		<c:if test='${"/" == resource.path}'>
}]
		</c:if>