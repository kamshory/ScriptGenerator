<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.Statement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.SQLException"%><%

String hostname = "";
String port = "";
String database = "";
String username = "";
String password = "";


hostname = (request.getParameter("hostname")==null)?"localhost":request.getParameter("hostname").toString();
port = (request.getParameter("port")==null)?"5432":request.getParameter("port").toString();
database = (request.getParameter("database")==null)?"":request.getParameter("database").toString();
username = (request.getParameter("username")==null)?"postgres":request.getParameter("username").toString();
password = (request.getParameter("password")==null)?"":request.getParameter("password").toString();

if(!hostname.equals("") && !port.equals("") && !database.equals("") && !username.equals("") && !password.equals(""))
{
Connection db_con;
Statement db_s;
ResultSet db_rs;
java.sql.PreparedStatement db_pst;

try
{
	String query = "select * from information_schema.tables where table_type = 'BASE TABLE' and table_schema = 'public'";
	
	Class.forName("org.postgresql.Driver");
	db_con = DriverManager.getConnection("jdbc:postgresql://"+hostname+":"+port+"/"+database, username, password);	
	db_s = db_con.createStatement();
	db_rs = db_s.executeQuery(query);
	out.print("[");
	int i = 0;
	while((db_rs.next()))
	{
		if(i>0)
		{
			out.print(",\r\n");
		}
		out.print("{\"table_catalog\":\""+db_rs.getString("table_catalog")+"\", \"table_name\":\""+db_rs.getString("table_name")+"\"}");	
		i++;
	}
	out.print("]");

}
catch(ClassNotFoundException | SQLException e)
{
	e.printStackTrace();
	out.print(e.getMessage());
}
finally
{
	
}
}


%>