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

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.jcr.Binary;
import javax.jcr.Node;
import javax.jcr.PathNotFoundException;
import javax.jcr.PropertyType;
import javax.jcr.RepositoryException;
import javax.jcr.Value;
import javax.jcr.ValueFactory;
import javax.servlet.Servlet;
import javax.servlet.ServletException;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.servlets.SlingAllMethodsServlet;

/**
 * Use Jasper instead.
 */
@Component
@Service(Servlet.class)
@Properties({
		@Property(name = "service.description", value = "Change a JSP on the fly."),
		@Property(name = "service.vendor", value = "Sandro Boehme"),
//		@Property(name = "sling.servlet.paths", value = "/content/mynode.jcrbrowser.dhtml")
//		@Property(name = "sling.servlet.selectors", value = "modify"),
//		@Property(name = "sling.servlet.extensions", value = "jsp"),
		@Property(name = "sling.servlet.methods", value = "PUT"),
		@Property(name = "sling.servlet.resourceTypes", value = "sling/servlet/default")

})
public class PUT extends SlingAllMethodsServlet {

	private static final long serialVersionUID = -1L;

	@Override
	protected void doPut(SlingHttpServletRequest request,
			SlingHttpServletResponse response) throws ServletException,
			IOException {

		Resource resource = request.getResource();
		if ("nt:file".equals(resource.getResourceType())){
			Resource contentResource = resource.getChild("jcr:content");
			if (contentResource!=null){
				Node contentNode = contentResource.adaptTo(Node.class);
				Node isNull = resource.adaptTo(Node.class);
				if (contentNode!=null){
					javax.jcr.Property dataProperty;
					InputStream stream = null;
					InputStream modifiedJspStream = null;
					try {
						dataProperty = contentNode.getProperty("jcr:data");
						if (dataProperty!=null && dataProperty.getType() == PropertyType.BINARY){
							long length = dataProperty.getLength();
							if (length > 0) {
								if (length < Integer.MAX_VALUE) {
									response.setContentLength((int) length);
								} else {
									response.setHeader("Content-Length", String.valueOf(length));
								}
								stream = dataProperty.getBinary().getStream();
								String jspString = readJSPStreamIntoString(stream);
								
								jspString = jspString.replace("<div id=\"new-text-id\"></div>", "<div id=\"new-text-id\"><h1>Yay, changed at the server side!</h1></div>");
								
								modifiedJspStream = new ByteArrayInputStream(jspString.getBytes("UTF-8"));
								ValueFactory valueFactory = contentNode.getSession().getValueFactory();
								Binary modifiedJSPBinary = valueFactory.createBinary(modifiedJspStream);
								Value createValue = valueFactory.createValue(modifiedJSPBinary);
								dataProperty.setValue(createValue);
								contentNode.getSession().save();
							}
						}
					} catch (PathNotFoundException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (RepositoryException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} finally {
						if (stream!=null) {
							stream.close();
						}
						if (modifiedJspStream!=null){
							modifiedJspStream.close();
						}
					}
				}
			}
		}
		response.getOutputStream().println("processed");
	}

	private String readJSPStreamIntoString(InputStream stream) {
		BufferedInputStream bis = new BufferedInputStream(stream);
	    ByteArrayOutputStream buf = new ByteArrayOutputStream();
	    try {
			int result = bis.read();
			while(result != -1) {
			  byte b = (byte)result;
			  buf.write(b);
			  result = bis.read();
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}        
	    return buf.toString();
	}
}
