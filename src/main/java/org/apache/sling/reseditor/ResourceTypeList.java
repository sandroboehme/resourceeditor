/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.apache.sling.reseditor;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.Servlet;
import javax.servlet.ServletException;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;
import org.apache.sling.commons.json.JSONArray;

/**
 * Queries the repository to get all available Sling resource types.
 */
@Component
@Service(Servlet.class)
@Properties({
		@Property(name = "service.description", value = "Queries the repository to get all available Sling resource types."),
		@Property(name = "service.vendor", value = "The Apache Software Foundation"),
		@Property(name = "sling.servlet.extensions", value = "json"),
		@Property(name = "sling.servlet.resourceTypes", value = "resource-editor/resource-type-list")
})
public class ResourceTypeList extends SlingSafeMethodsServlet {

	private static final long serialVersionUID = -1L;
	private static final String STATEMENT = "SELECT [sling:resourceType] FROM [nt:base] WHERE [sling:resourceType] is not null";
	private static final String QUERY_TYPE = "JCR-SQL2";

	@Override
	protected void doGet(SlingHttpServletRequest request,
			SlingHttpServletResponse response) throws ServletException,
			IOException {
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		Set<String> resourceTypes = new HashSet<String>();
        ResourceResolver resolver = request.getResourceResolver();
        Iterator<Map<String, Object>> result = resolver.queryResources(STATEMENT, QUERY_TYPE);
        while (result.hasNext()) {
			Map<String, Object> row = (Map<String, Object>) result.next();
			String resourceType = (String) row.get("sling:resourceType");
			resourceTypes.add(resourceType);
		}
        String[] resourceTypesArray = resourceTypes.toArray(new String[resourceTypes.size()]);
		List<String> sortList = new LinkedList<String>(Arrays.asList(resourceTypesArray));
        Collections.sort(sortList);
        final JSONArray json = new JSONArray(sortList);
		response.getWriter().write(json.toString());
	}
}
