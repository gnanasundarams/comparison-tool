package com.ask.mammoth.compare;

import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.nio.SelectChannelConnector;
import org.mortbay.jetty.servlet.HashSessionIdManager;
import org.mortbay.jetty.webapp.WebAppContext;
import org.mortbay.thread.BoundedThreadPool;

public class DisplayResults {


	public static void main(String[] args) {
		Server server = new Server();
		Connector connector = new SelectChannelConnector();
		int port = 5015;
		connector.setPort(port);
		//connector.setHost("127.0.0.1");
		server.addConnector(connector);
		BoundedThreadPool pool = new BoundedThreadPool();
		pool.setLowThreads(1);
		pool.setMaxThreads(10000);
		pool.setMinThreads(10);

		server.setThreadPool(pool);
		server.addConnector(connector);
		HashSessionIdManager mgr = new HashSessionIdManager(
				new java.util.Random());
		mgr.setWorkerName("node1");
		server.setSessionIdManager(mgr);

		WebAppContext wac = new WebAppContext();
		wac.setContextPath("/");
		wac.setWar("./web"); // this is path to .war OR TO expanded, existing
								// webapp; WILL FIND web.xml and parse it
		wac.setMaxFormContentSize(2 * 1024 * 1024);

		server.setHandler(wac);
		server.setStopAtShutdown(true);

		try {
			server.start();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
