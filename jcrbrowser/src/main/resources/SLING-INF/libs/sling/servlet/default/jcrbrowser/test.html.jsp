<!DOCTYPE html>
<%@ page session="false"%>
<%@ page isELIgnored="false"%>
<%@ page import="javax.jcr.*,org.apache.sling.api.resource.Resource"%>
<%@ page import="java.security.Principal"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%>
<sling:defineObjects />
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet" type="text/css" media="all" href="<%= request.getContextPath() %>/libs/jcrbrowser/content/css/bootstrap.css">


</head>
<body>
	<div id="container-fluid" class="container-fluid">
		<div class="row">
			<div class="col-sm-4">
				<div id="sidebar" class="plate">
					<div id="treee" class="demos roott" ></div>
				</div>
			</div>
			<div class="col-sm-8">
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
										<label class="proplabel" for='${property.name}'>${property.name} [<%=PropertyType.nameFromValue(property.getType())%>${property.multiple ? ' multiple' : ''}]</label>
										<c:choose>
										     <c:when test="${property.multiple}" >
										     	<fieldset class="propmultival_fieldset">
										     		<div>&nbsp;</div>
										     	<c:forEach var="value" items="<%=property.getValues()%>">
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
											     <c:when test="<%=property.getType() == PropertyType.BINARY%>" >
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
	</div>
</body>
</html>
