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
package org.sboehme.jcrbrowser;

import javax.servlet.http.HttpServletRequest;

import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceDecorator;
import org.apache.sling.api.resource.ResourceWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 
 * @scr.component immediate="true" label="%defaultRtp.name"
 *                description="%defaultRtp.description"
 * @scr.property name="service.vendor" value="Sandro Boehme"
 * @scr.property name="service.description" value="Sample Resource Decorator"
 * @scr.service
 */
public class AppPathDecorator implements ResourceDecorator {

	private final Logger log = LoggerFactory.getLogger(getClass());

	/**
	 * @see org.apache.sling.api.resource.ResourceDecorator#decorate(org.apache.sling.api.resource.Resource,
	 *      javax.servlet.http.HttpServletRequest)
	 */
	public Resource decorate(Resource resource, HttpServletRequest request) {
		Resource result = null;
		String pathInfo = request.getPathInfo();
		if (pathInfo != null && pathInfo.startsWith("/browser")) {
			result = new ResourceWrapper(resource) {

				@Override
				public boolean isResourceType(String resourceType) {
					// TODO Auto-generated method stub
					return "browsernode".equals(resourceType);//super.isResourceType(resourceType);
				}

				@Override
				public String getResourceType() {
					String resourceType = getResource().getResourceType();
					return "browsernode";
//					return "servletresourcetype";
//					return resourceType;//"browsernode";
				}

			};
		}
		return result;
	}

	/** Return a resource type for given node, if we have a mapping that applies */
	public Resource decorate(Resource resource) {
		return null;
	}
}