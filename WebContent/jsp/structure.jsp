<%@ page import = "java.nio.charset.*" %><%@ page import = "org.apache.commons.codec.binary.Base64" %><%@ page import="java.io.*,java.util.*, javax.servlet.*" %><%@ page import="java.sql.DriverManager"%><%@ page import="java.sql.Statement"%><%@ page import="java.sql.ResultSet"%><%@ page import="java.sql.Connection"%><%@ page import="java.sql.SQLException"%><%!

public Connection db_con;
public Statement db_s;
public ResultSet db_rs;
public java.sql.PreparedStatement db_pst;

public String showAlterTable(String table)
{
	String ret = "";
	ret += "ALTER TABLE "+table+" ADD COLUMN "+table+"_apv_id bigint;\r\n";
	ret += "ALTER TABLE "+table+" ALTER COLUMN "+table+"_apv_id SET DEFAULT 0;\r\n";
	return ret;
}
public String showCreateTable(String table)
{
	ResultSet rs, rs2;
	String ret = "";
	int nField = 0, nField2 = 0, i = 0, j = 0;
	String query = "SELECT * FROM information_schema.columns WHERE table_name = '"+table+"' ";
	String curtype = "";
	try
	{
		db_s = db_con.createStatement();
		rs = db_s.executeQuery(query); 
		if(rs.isBeforeFirst())
		{
			while((rs.next()))
			{
				nField++;
			}
		}
		db_s = db_con.createStatement();
		rs = db_s.executeQuery(query); 
		if(db_rs.isBeforeFirst())
		{
			ret += "-- DROP TABLE "+table+";\r\n\r\n";
			ret += "CREATE TABLE "+table+"\r\n(\r\n";
			while((rs.next()))
			{
				i++;
				ret += "\t"+rs.getString("column_name")+" ";
				if(rs.getString("column_default") != null)
				{
					if(rs.getString("column_default").contains("nextval("))
					{
						if(rs.getString("data_type").equals("bigint"))
						{
							ret += "bigserial";
							curtype = "bigserial";
						}
						else
						{
							ret += "serial";
							curtype = "serial";
						}
					}
					else
					{
						ret += rs.getString("data_type");
						curtype = rs.getString("data_type");
					}
				}
				else
				{
					ret += rs.getString("data_type");
					curtype = rs.getString("data_type");
				}
				if(rs.getInt("character_maximum_length") > 0 )
				{
					ret += "("+rs.getInt("character_maximum_length")+")";
				}
				if(rs.getString("is_nullable").equals("NO"))
				{
					ret += " NOT NULL";
				}
				if(rs.getString("column_default") != null)
				{
					if(!curtype.equals("serial") && !curtype.equals("bigserial"))
					{
						ret += " DEFAULT "+rs.getString("column_default");
					}
				}
				
				if(i < nField)
				{
					ret += ",\r\n";
				}
			}			
			query = "SELECT * FROM information_schema.key_column_usage WHERE table_name = '"+table+"' ";
			db_s = db_con.createStatement();
			rs2 = db_s.executeQuery(query);
			if(rs2.isBeforeFirst())
			{
				while((rs2.next()))
				{
					nField2++;
				}
			}
			db_s = db_con.createStatement();
			rs2 = db_s.executeQuery(query);
			if(rs2.isBeforeFirst())
			{
				ret += ",\r\n";
				while((rs2.next()))
				{
					j++;
					System.out.println(rs2.getString("constraint_name"));
					System.out.println(rs2.getString("table_name")+"_pkey");
					if(rs2.getString("constraint_name").contains(rs2.getString("table_name")+"_pkey"))
					{
						ret += "\tCONSTRAINT "+rs2.getString("constraint_name").replaceAll(" ", "_")+" PRIMARY KEY ("+rs2.getString("column_name")+")";
					}
					else
					{
						ret += "\tCONSTRAINT "+rs2.getString("constraint_name").replaceAll(" ", "_")+" UNIQUE ("+rs2.getString("column_name")+")";
					}
					if(j < nField2)
					{
						ret += ",\r\n";
					}
				}
			}
			ret += "\r\n";			
			ret += ")\r\n";
			ret += "WITH (\r\n\tOIDS=FALSE\r\n);\r\n\r\n";
		}
	}
	catch(SQLException e)
	{		
	}
	finally
	{
	}
	return ret;
}
public String getPrimaryKey(String table)
{
	String query = "";
	query = "SELECT * FROM information_schema.key_column_usage WHERE table_name = '"+table+"' ";
	try
	{
		db_s = db_con.createStatement();
		ResultSet rs = db_s.executeQuery(query);
		if(rs.isBeforeFirst())
		{
			while((rs.next()))
			{
				if(rs.getString("constraint_name").contains(rs.getString("table_name")+"_pkey"))
				{
					return rs.getString("column_name");
				}
			}
		}
	}
	catch(SQLException e)
	{		
	}
	finally
	{
	}
	return "";
}
public String showCreateTableApproval(String table)
{
	ResultSet rs, rs2;
	String ret = "";
	int nField = 0, nField2 = 0, i = 0, j = 0;
	String query = "SELECT * FROM information_schema.columns WHERE table_name = '"+table+"' and column_name != '"+table+"_apv_id' ";
	String curtype = "";
	try
	{
		db_s = db_con.createStatement();
		rs = db_s.executeQuery(query);
		if(rs.isBeforeFirst())
		{
			while((rs.next()))
			{
				nField++;
			}
		}
		db_s = db_con.createStatement();
		rs = db_s.executeQuery(query);
		if(rs.isBeforeFirst())
		{
			ret += "-- DROP TABLE "+table+"_apv;\r\n\r\n";
			ret += "CREATE TABLE "+table+"_apv\r\n(\r\n";
			ret += "\t"+table+"_apv_id bigserial NOT NULL,\r\n";
			while((rs.next()))
			{
				i++;
				ret += "\t"+rs.getString("column_name")+" ";
				ret += rs.getString("data_type");
				curtype = rs.getString("data_type");
				if(rs.getInt("character_maximum_length") > 0 )
				{
					ret += "("+rs.getInt("character_maximum_length")+")";
				}
				if(rs.getString("is_nullable").equals("NO"))
				{
					// ret += " NOT NULL";
				}
				if(rs.getString("column_default") != null)
				{
					if(!rs.getString("column_default").contains("nextval("))
					{
						ret += " DEFAULT "+rs.getString("column_default");
					}
				}
				
				if(i < nField)
				{
					ret += ",\r\n";
				}
			}
			
			// Additional Column
			
			ret += ",\r\n\tadmin_create_id bigint,\r\n";
			ret += "\tadmin_approve_id bigint,\r\n";
			ret += "\ttime_create timestamp without time zone DEFAULT (now())::timestamp without time zone,\r\n";
			ret += "\ttime_approve timestamp without time zone,\r\n";
			ret += "\tip_create character varying(50),\r\n";
			ret += "\tip_approve character varying(50),\r\n";
			ret += "\tstatus_approve smallint default 0,\r\n";
			ret += "\tstatus_data smallint default 0";
			
			ret += ",\r\n\tCONSTRAINT "+table+"_apv_pkey PRIMARY KEY ("+table+"_apv_id)";
			ret += "\r\n";			
			ret += ")\r\n";
			ret += "WITH (\r\n\tOIDS=FALSE\r\n);\r\n\r\n";
		}
	}
	catch(SQLException e)
	{		
	}
	finally
	{
	}
	return ret;
}
public String showCreateTableTrash(String table, boolean withApproval)
{
	ResultSet rs, rs2;
	String ret = "";
	int nField = 0, nField2 = 0, i = 0, j = 0;
	String query = "SELECT * FROM information_schema.columns WHERE table_name = '"+table+"' and column_name != '"+table+"_apv_id' ";
	String curtype = "";
	try
	{
		db_s = db_con.createStatement();
		rs = db_s.executeQuery(query);
		if(rs.isBeforeFirst())
		{
			while((rs.next()))
			{
				nField++;
			}
		}
		db_s = db_con.createStatement();
		rs = db_s.executeQuery(query);
		if(rs.isBeforeFirst())
		{
			ret += "-- DROP TABLE "+table+"_trash;\r\n\r\n";
			ret += "CREATE TABLE "+table+"_trash\r\n(\r\n";
			ret += "\t"+table+"_trash_id bigserial NOT NULL,\r\n";
			ret += "\tadmin_delete_id bigint,\r\n";
			ret += "\ttime_delete timestamp without time zone NOT NULL DEFAULT (now())::timestamp without time zone,\r\n";
			ret += "\tip_address_delete character varying(50),\r\n";
			
			while((rs.next()))
			{
				i++;
				ret += "\t"+rs.getString("column_name")+" ";
				ret += rs.getString("data_type");
				curtype = rs.getString("data_type");
				if(rs.getInt("character_maximum_length") > 0 )
				{
					ret += "("+rs.getInt("character_maximum_length")+")";
				}
				if(rs.getString("is_nullable").equals("NO"))
				{
					ret += " NOT NULL";
				}
				if(rs.getString("column_default") != null)
				{
					if(!rs.getString("column_default").contains("nextval("))
					{
						ret += " DEFAULT "+rs.getString("column_default");
					}
				}
				
				if(i < nField)
				{
					ret += ",\r\n";
				}
			}
			
			if(withApproval)
			{
				ret += ",\r\n\t"+table+"_apv_id bigint NOT NULL DEFAULT 0";
			}
			
			ret += ",\r\n\tCONSTRAINT "+table+"_trash_pkey PRIMARY KEY ("+table+"_trash_id)";
			ret += "\r\n";			
			ret += ")\r\n";
			ret += "WITH (\r\n\tOIDS=FALSE\r\n);\r\n\r\n";
		}
	}
	catch(SQLException e)
	{		
	}
	finally
	{
	}
	return ret;
}
public String createTriggerBeforeDelete(String table, String column, String pkey)
{
	String ret = "";
	ret += 
	"CREATE OR REPLACE FUNCTION fn_before_delete_"+table+"() RETURNS TRIGGER AS $$\r\n"+
	"BEGIN\r\n"+	
	"	INSERT INTO "+table+"_trash ("+column+") select "+column+" from "+table+" where "+table+"."+pkey+" = OLD."+pkey+";\r\n"+
	"    RETURN OLD;\r\n"+
	"END;\r\n"+
	"$$ LANGUAGE plpgsql;\r\n"+
	"\r\n"+
	"DROP TRIGGER IF EXISTS before_delete_"+table+" ON "+table+";\r\n"+
	"CREATE TRIGGER before_delete_"+table+"\r\n"+
	"BEFORE DELETE ON "+table+"\r\n"+
	"FOR EACH ROW\r\n"+ 
	"EXECUTE PROCEDURE fn_before_delete_"+table+"();\r\n";	
	return ret;
}
public static String base64Encode(String token) {
    byte[] encodedBytes = Base64.encodeBase64(token.getBytes());
    return new String(encodedBytes, Charset.forName("UTF-8"));
}

public static String base64Decode(String token) {
    byte[] decodedBytes = Base64.decodeBase64(token.getBytes());
    return new String(decodedBytes, Charset.forName("UTF-8"));
}


%><%

String hostname = "";
String port = "";
String database = "";
String username = "";
String password = "";
String table = "";

hostname = (request.getParameter("hostname")==null)?"localhost":request.getParameter("hostname").toString();
port = (request.getParameter("port")==null)?"5432":request.getParameter("port").toString();
database = (request.getParameter("database")==null)?"":request.getParameter("database").toString();
username = (request.getParameter("username")==null)?"postgres":request.getParameter("username").toString();
password = (request.getParameter("password")==null)?"":request.getParameter("password").toString();
table = (request.getParameter("table")==null)?"":request.getParameter("table").toString();

if(!hostname.equals("") && !port.equals("") && !database.equals("") && !username.equals("") && !password.equals("") && !table.equals(""))
{

try
{
	String query = "SELECT * FROM information_schema.columns WHERE table_name = '"+table+"' and column_name != '"+table+"_apv_id' ";
	String SQL = "";
	Class.forName("org.postgresql.Driver");
	db_con = DriverManager.getConnection("jdbc:postgresql://"+hostname+":"+port+"/"+database, username, password);	
	db_s = db_con.createStatement();
	db_rs = db_s.executeQuery(query);
	out.print("{\"fields\":[");
	int i = 0;
	String column = "";
	while((db_rs.next()))
	{
		if(i>0)
		{
			out.print(",\r\n");
			column += ", ";
		}
		column += db_rs.getString("column_name");
		out.print("{\"column_name\":\""+db_rs.getString("column_name")+"\", \"data_type\":\""+db_rs.getString("data_type")+"\"}");
		
		i++;
	}
	String pkey = getPrimaryKey(table);
	SQL += "-- ALTER TABLE "+table+"\r\n";
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += showAlterTable(table);
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += "\r\n\r\n";

	SQL += "-- TABLE "+table+"_apv\r\n";
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += showCreateTableApproval(table);
	SQL += "-- ---------------------------------------------------------\r\n";

	SQL += "\r\n\r\n";
	
	

	SQL += "-- TABLE "+table+"_trash (with approval)\r\n";
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += showCreateTableTrash(table, true);
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += "-- "+table+"_trash (with approval)\r\n";

	SQL += "\r\n\r\n";

	
	SQL += "-- Trigger Before Delete "+table+" (with approval)\r\n";
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += createTriggerBeforeDelete(table, column+", "+table+"_apv_id", pkey);
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += "-- Trigger Before Delete "+table+" (with approval)\r\n\r\n";
	
	SQL += "\r\n";
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += "\r\n\r\n";
	
	SQL += "-- TABLE "+table+"_trash (without approval)\r\n";
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += showCreateTableTrash(table, false);
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += "-- "+table+"_trash (without approval)\r\n";

	SQL += "\r\n\r\n";

	
	SQL += "-- Trigger Before Delete "+table+" (without approval)\r\n";
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += createTriggerBeforeDelete(table, column, pkey);
	SQL += "-- ---------------------------------------------------------\r\n";
	SQL += "-- Trigger Before Delete "+table+" (without approval)\r\n\r\n";

	SQL += "\r\n\r\n";

	
	
	out.print("], \"query\":\""+base64Encode(SQL)+"\"}");

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