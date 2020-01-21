<%-- 
    Document   : supplierCheck
    Created on : 2020/01/20, 18:24:15
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.io.*, java.util.*"%>
<%
    
    // 取引先コード取得
    String supplierCode = request.getParameter("supplierCode");
        
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    // Jsonデータ
    String resJson = "";

    // 取引先情報取得
    String suppliersSql = "select s.SUPPLIER_CODE, s.SUPPLIER_NAME "
                    + "from SUPPLIERS s "
                    + "where s.DELETE_FLAG = false "
                    + "and s.SUPPLIER_CODE = '" + supplierCode + "' ";

    ResultSet rs = da.getResultSet(suppliersSql);
    
    // Json生成
    if(rs.next()){
        resJson += "{\"supplierCode\":\"" + rs.getString("SUPPLIER_CODE") + "\",";
        resJson += "\"supplierName\":\"" + rs.getString("SUPPLIER_NAME") + "\"}";        
    }
        
    System.out.println(resJson);
    
    response.setContentType("application/json;charset=UTF-8");
    
    PrintWriter pw = response.getWriter();// pwオブジェクト
    pw.print(resJson); // 出力
    pw.close();

%>
