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
					"id" : "/",
            		"text"	: "/",
            		"state" : {"opened":true, "disabled": false, "selected": false},
					"a_attr" :{
							"target" : "<%= request.getContextPath() %>/",
		           			"href" : "JavaScript:void(0);"
					},
					"li_attr" :{
							"nodename" : "${theResource.name}"
					},
            		"children" :
		</c:if>
	[
			<c:forEach var="theResource" items="<%=resource.listChildren()%>" varStatus="status">
				<% 
				Resource theResource = (Resource) pageContext.getAttribute("theResource");
				String aPath = request.getContextPath() + theResource.getPath();
				// TODO Find out why e.g. '//apps/sling' has two slashes 
				String thePath = aPath.startsWith("//") ? aPath.substring(1) : aPath;
				%>
		{
			"a_attr" :{
					"target" : "<%= java.net.URLEncoder.encode(thePath, "UTF-8").replaceAll("%2F", "/").replaceAll("%3A", ":") %>",
           			"href" : "JavaScript:void(0);"
			},
			"li_attr" :{
					"nodename" : "${theResource.name}"
			},
				
            "text"	: "${theResource.name} [<span class=\"node-type\">${theResource.resourceType}</span>]",
            "children" : <%= theResource.listChildren().hasNext() %>
		}${!status.last ? ',': ''}
			</c:forEach>
	]

		<c:if test='${"/" == resource.path}'>
}]
		</c:if>