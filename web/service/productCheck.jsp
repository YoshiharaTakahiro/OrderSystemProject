<%-- 
    Document   : productCheck
    Created on : 2020/01/15, 17:09:49
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.io.*, java.util.*"%>
<%
    
    // 商品コード取得
    String productCode = request.getParameter("productCode");
    
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    // Jsonデータ
    String resJson = "";

    // 商品情報取得
    String prodcutSql = "select distinct p.PRODUCT_CODE, p.PRODUCT_NAME "
                    + "from PRODUCTS p "
                    + "where p.DELETE_FLAG = false "
                    + "and p.PRODUCT_CODE = '" + productCode + "' ";

    ResultSet rs = da.getResultSet(prodcutSql);
    
    // Json生成
    while(rs.next()){
        resJson += "{\"productName\":\"" + rs.getString("PRODUCT_NAME") + "\",";
    }
    
    // カラーコード
    String colorSql = "select p.COLOR_CODE, c.COLOR "
            + "from PRODUCTS p, COLORS c "
            + "where p.COLOR_CODE = c.COLOR_CODE "
            + "and p.DELETE_FLAG = false "
            + "and p.PRODUCT_CODE = '" + productCode + "' ";

    rs = da.getResultSet(colorSql);
    
    // Json生成（カラーコード）
    resJson += "\"colors\":[";
    while(rs.next()){
        resJson += "{\"colorCode\":\"" + rs.getString("COLOR_CODE") + "\",";
        resJson += "\"color\":\"" + rs.getString("COLOR") + "\"},";        
    }
    resJson = resJson.substring(0, resJson.length()-1);
    resJson += "]}";
    
    System.out.println(resJson);
    
    response.setContentType("application/json;charset=UTF-8");
    
    PrintWriter pw = response.getWriter();// pwオブジェクト
    pw.print(resJson); // 出力
    pw.close();

%>