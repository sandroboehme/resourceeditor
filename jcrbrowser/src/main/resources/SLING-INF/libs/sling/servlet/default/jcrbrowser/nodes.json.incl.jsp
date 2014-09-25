
[
	<c:forEach var="theResource" items="<%=resource.listChildren()%>" varStatus="status">
		<% Resource theResource = (Resource) pageContext.getAttribute("theResource");%>
	{
        "text": "<i class=\"jstree-icon open-icon\"></i>${fn:escapeXml(theResource.name)} [<span class=\"node-type\">${theResource.resourceType}</span>]",
		"li_attr": { "nodename" : "${fn:escapeXml(theResource.name)}" },
		"a_attr": { "href" : "${fn:escapeXml(theResource.path)}.jcrbrowser.html" },
        "children" : <%= theResource.listChildren().hasNext() %> <%--${theResource.listChildren().hasNext()} will work in Servlet 3.0 --%>
	}${!status.last ? ',': ''}
	</c:forEach>
]
