<%-- 
    Document   : supplierCheck
    Created on : 2020/01/20, 18:24:15
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.io.*, java.util.*, javax.json.*"%>
<%
    
    // 取引先コード取得
    String supplierCode = request.getParameter("supplierCode");
        
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    // Jsonオブジェクトビルダー
    JsonObjectBuilder JsonObjB = Json.createObjectBuilder();

    // 取引先情報取得
    String suppliersSql = "select s.SUPPLIER_CODE, s.SUPPLIER_NAME "
                    + "from SUPPLIERS s "
                    + "where s.DELETE_FLAG = false "
                    + "and s.SUPPLIER_CODE = '" + supplierCode + "' ";

    ResultSet rs = da.getResultSet(suppliersSql);
    
    // Json生成
    if(rs.next()){
        JsonObjB.add("supplierCode", rs.getString("SUPPLIER_CODE"));        
        JsonObjB.add("supplierName", rs.getString("SUPPLIER_NAME"));        
    }
        
    // 文字列に変換
    String jsonString;
    Writer writer = new StringWriter();
    Json.createWriter(writer).write(JsonObjB.build());
    jsonString = writer.toString();
    
    System.out.println(jsonString);
    
    response.setContentType("application/json;charset=UTF-8");
    
    PrintWriter pw = response.getWriter();// pwオブジェクト
    pw.print(jsonString); // 出力
    pw.close();

%>
