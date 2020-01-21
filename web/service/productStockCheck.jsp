<%-- 
    Document   : productStockCheck
    Created on : 2020/01/19, 17:19:17
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.io.*, java.util.*"%>
<%
    
    // 商品コード、カラーコード取得
    String productCode = request.getParameter("productCode");
    String colorCode = request.getParameter("colorCode");
        
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    // Jsonデータ
    String resJson = "";

    // 商品情報取得
    String prodcutSql = "select p.STOCK, p.ALLOCATION, p.PRICE "
                    + "from PRODUCTS p "
                    + "where p.DELETE_FLAG = false "
                    + "and p.PRODUCT_CODE = '" + productCode + "' "
                    + "and p.COLOR_CODE = '" + colorCode + "' ";

    ResultSet rs = da.getResultSet(prodcutSql);
    
    // Json生成
    if(rs.next()){
        resJson += "{\"stock\":" + rs.getInt("STOCK") + ",";
        resJson += "\"allocation\":" + rs.getInt("ALLOCATION") + ",";
        resJson += "\"price\":" + rs.getInt("PRICE") + "}";        
    }
        
    System.out.println(resJson);
    
    response.setContentType("application/json;charset=UTF-8");
    
    PrintWriter pw = response.getWriter();// pwオブジェクト
    pw.print(resJson); // 出力
    pw.close();

%>
