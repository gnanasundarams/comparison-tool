<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.util.*,java.text.*,org.apache.solr.client.solrj.*,org.apache.solr.client.solrj.impl.HttpSolrServer,org.apache.commons.*,org.apache.solr.common.params.ModifiableSolrParams,org.apache.solr.common.*,org.apache.solr.client.solrj.response.*,java.util.Iterator,java.util.Date,java.text.SimpleDateFormat"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head><title>COMPARE</title></head>
<body>
<%! static HttpSolrServer offlineSolr;
	static HttpSolrServer onlineSolr;
	static {
		offlineSolr = new HttpSolrServer("http://msolroff004iad.io.askjeeves.info:8983/solr/content/");
		onlineSolr = new HttpSolrServer("http://msolroff004iad.io.askjeeves.info:8983/solr/content/");
	}
%>
<% 
String q = request.getParameter("q") != null ? request.getParameter("q")
		: "";

	ModifiableSolrParams params = new ModifiableSolrParams();
	params.set("q", "*:*");
	params.set("sort", "cmeta_last_modified_date desc");
	params.set("fl","cmeta_last_modified_date");
	params.set("rows", "1");
	long startTime = System.currentTimeMillis();
	QueryResponse qr = onlineSolr.query(params);
	long endTime = System.currentTimeMillis();
	long timetaken = endTime - startTime;
	if (qr != null && qr.getResults() != null) {
		SolrDocumentList sdl = qr.getResults();
		String latestDocTime = null;
		long onlineNumFound = 0;
		long offlineNumFound = 0;
		long noOfDocsChangedOffline = 0;
		if(!sdl.isEmpty()){
			onlineNumFound = sdl.getNumFound();		
			%>
			<div>Number of results found in online: <span style="font-weight: bold"><%=onlineNumFound%></span></div>
			<div>Time taken: <span><%=timetaken%> milliseconds</span></div>
			<%
			String actualTime= null;
			int count = 1;
			for (SolrDocument d : sdl) {
				Date s = (Date)d.getFieldValue("cmeta_last_modified_date");
				actualTime = s.toString();
				DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH\\:mm\\:ss'Z'");
				latestDocTime=formatter.format(s);
			}
		}
	
	ModifiableSolrParams params1 = new ModifiableSolrParams();
	params1.set("q", "*:*");
	params1.set("fl","contentid");
	params1.set("rows", "1");
	long startOff = System.currentTimeMillis();
	QueryResponse qr1 = offlineSolr.query(params1);
	long endOff = System.currentTimeMillis();
	long timeToQueryOff = endOff - startOff;
	if (qr1 != null && qr1.getResults() != null) {
		SolrDocumentList sdl1 = qr1.getResults();
		if(!sdl1.isEmpty()){
			offlineNumFound = sdl1.getNumFound();
		}
	} %>
	<div>Number of results found in offline: <span style="font-weight: bold"><%=offlineNumFound%></span></div>
	<%
		ModifiableSolrParams params2 = new ModifiableSolrParams();
		params2.set("fl","title,cmeta_last_modified_date,contentid");
		//params2.set("q","cmeta_last_modified_date:[ "+latestDocTime+" TO * ]" );
		params2.set("q","cmeta_last_modified_date:[ 2016-03-08T16\\:43\\:38Z TO * ]" );
		params2.set("rows","1000");
		long start = System.currentTimeMillis();
		QueryResponse qr2 = offlineSolr.query(params2);
		long end = System.currentTimeMillis();
		 long time1 = end - start;
		if (qr2 != null && qr2.getResults() != null) {
			SolrDocumentList sdl2 = qr2.getResults();
			if(!sdl2.isEmpty()){
				noOfDocsChangedOffline = sdl2.getNumFound();
				%>
				<div>Number of documents changed in Offline after last sync: <span style="font-weight: bold"><%=noOfDocsChangedOffline%></span></div>
				
				<div style="font-weight: bold; margin-top: 16px">Last modified article titles:</div>
				<table border="1">
				<%
				for (SolrDocument d : sdl2) {
					%><tr><%
					String title = (String)d.getFieldValue("title");
					%><td><%=title%></td><%
					%></tr><%
					}%>
					</table>
				<%	
			}}	
				
	}  


%>
</body>
</html>