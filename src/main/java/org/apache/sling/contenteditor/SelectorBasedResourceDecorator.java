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
package org.apache.sling.contenteditor;

import javax.servlet.http.HttpServletRequest;

import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceDecorator;
import org.apache.sling.api.resource.ResourceMetadata;
import org.apache.sling.api.resource.ResourceWrapper;

/**
 * Overrules the resource resolver to let the Sling Content Editor render servlets that
 * have been registered by path.
 * 
 * E.g. the login servlet is registered by path using the URL
 * /system/sling/login. When calling /system/sling/login.contenteditor.html the
 * servlet would usually be called to render the request. To render this
 * resource with the Sling Content Editor instead, this ResourceDecorator removes the 
 * servlet resource type for requests that use the 'contenteditor' selector in 
 * the path.
 * 
 * @scr.component immediate="true" label="%defaultRtp.name" description="%defaultRtp.description"
 * @scr.property name="service.vendor" value="The Apache Software Foundation"
 * @scr.property name="service.description" value="Sling Content Editor extension Resource Decorator"
 * @scr.service
 */
public class SelectorBasedResourceDecorator implements ResourceDecorator {

	private static final String CONTENTEDITOR_RESOURCE_TYPE = "contenteditor";
	private static final String CONTENTEDITOR_SELECTOR = "contenteditor";

	/**
	 * @see org.apache.sling.api.resource.ResourceDecorator#decorate(org.apache.sling.api.resource.Resource,
	 *      javax.servlet.http.HttpServletRequest)
	 */
	public Resource decorate(Resource resource, HttpServletRequest request) {
		String pathInfo = request.getPathInfo();
		return getContentEditorResourceWrapper(resource,
				pathInfo);
	}

	/**
	 * @see org.apache.sling.api.resource.ResourceDecorator#decorate(org.apache.sling.api.resource.Resource)
	 */
	public Resource decorate(Resource resource) {
		Resource result = null;
		if (resource != null) {
			ResourceMetadata resourceMetadata = resource.getResourceMetadata();
			if (resourceMetadata != null) {
				String resolutionPathInfo = resourceMetadata.getResolutionPathInfo();
				result = getContentEditorResourceWrapper(resource,resolutionPathInfo);
			}
		}
		return result;
	}

	private Resource getContentEditorResourceWrapper(Resource resource, String resolutionPathInfo) {
		Resource result = null;
		if (resolutionPathInfo != null && resolutionPathInfo.endsWith("." + CONTENTEDITOR_SELECTOR + ".html")) {
			result = new ResourceWrapper(resource) {
				@Override
				public String getResourceType() {
					/*
					 * It overwrites the resource types to avoid that the servlet 
					 * resource types have a higher priority then the
					 * Content Editor's html.jsp.
					 */
					return CONTENTEDITOR_RESOURCE_TYPE;
				}

			};
		}
		return result;
	}
}