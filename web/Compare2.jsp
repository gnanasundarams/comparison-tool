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
		onlineSolr = new HttpSolrServer("http://msolronl007iad.io.askjeeves.info:8983/solr/content/");
	}
%>
<% 
String doc1 = null;
String doc2 = null;
Set<String> firstSet =  new HashSet<String>();
Set<String> secondSet = new HashSet<String>();
String q = request.getParameter("q") != null ? request.getParameter("q")
		: "";
if(!q.isEmpty()) {%>
	<div>Query: <span style="font-weight: bold"><%=q%></span></div>
	<% 
ModifiableSolrParams params = new ModifiableSolrParams();
params.set("q", q);
params.set("sort", "cmeta_last_modified_date desc");
params.set("fl","cmeta_last_modified_date,contentid");
long startTime = System.currentTimeMillis();
QueryResponse qr = onlineSolr.query(params);
long endTime = System.currentTimeMillis();
long timetaken = endTime - startTime;
if (qr != null && qr.getResults() != null) {
	SolrDocumentList sdl = qr.getResults();
	if(!sdl.isEmpty()){
		long numFound = sdl.getNumFound();
		
		%>
		<div>Number of results found: <span style="font-weight: bold"><%=numFound%></span></div>
		<div>Time taken: <span style="font-weight: bold"><%=timetaken%></span></div>
		<%
		String latestDocTime = null;
		String actualTime= null;
		int count = 1;
		for (SolrDocument d : sdl) {
			firstSet.add((String)d.getFieldValue("contentid"));
			//if(count==100) {
			//Date s = (Date)d.getFieldValue("cmeta_last_modified_date");
			//actualTime = s.toString();
			//DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd'T'HH\\:mm\\:ss'Z'");
			//latestDocTime=formatter.format(s);
			%>
			
			<%-- Latest Document Time: <%=latestDocTime%>
			Actual Document Time: <%=actualTime%> --%>
			<%
			//}
			count++;
		}
		%>
		First Set size: <%=firstSet.size()%>		
		<%-- Changed Time: <%=latestDocTime%> --%>
		<%
		ModifiableSolrParams params1 = new ModifiableSolrParams();
		params1.set("fl","title,cmeta_last_modified_date,contentid");
		params1.set("rows","81");
		params1.set("q","cmeta_last_modified_date:[ 2016-03-08T16\\:43\\:38Z TO * ]" );
		long start = System.currentTimeMillis();
		QueryResponse qr1 = offlineSolr.query(params1);
		long end = System.currentTimeMillis();
		 long time1 = end - start;
		if (qr1 != null && qr1.getResults() != null) {
			SolrDocumentList sdl1 = qr1.getResults();
			if(!sdl1.isEmpty()){
				long numFound1 = sdl1.getNumFound();
				%>
				<div>Number of results found for time gap: <span style="font-weight: bold"><%=numFound1%></span></div>
				<div style="font:bold">Last modified article titles</div>
				<%
				for (SolrDocument d : sdl1) {
					secondSet.add((String)d.getFieldValue("contentid"));
					String title = (String)d.getFieldValue("title"); 
					//Date time = (Date)d.getFieldValue("cmeta_last_modified_date"); %>
					<%-- <div><%=title%><span>    </span><%=time.toString()%></div>--%>					
			<%	}%>
				Second Set size: <%=secondSet.size()%>
					<%
					Set<String> one = new HashSet<String>(firstSet);
					
					one.removeAll(secondSet); 
					%>
					 After removal : <%=one.size()%>
					 Time taken : <%=time1%>
				<%	
			}}	
				
	} } } else {
		
	}


%>
</body>
</html>