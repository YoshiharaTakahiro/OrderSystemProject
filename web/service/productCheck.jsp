<%-- 
    Document   : productCheck
    Created on : 2020/01/15, 17:09:49
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.io.*, java.util.*, javax.json.*"%>
<%
    
    // 商品コード取得
    String productCode = request.getParameter("productCode");
    
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    // Jsonオブジェクトビルダー
    JsonObjectBuilder JsonObjB = Json.createObjectBuilder();
    JsonArrayBuilder colorArrayB = Json.createArrayBuilder();
    
    // 商品存在チェック
    int cnt = 0;
    String prodcutSql = "select count(*) as CNT "
                      + "from PRODUCTS p "
                      + "where p.DELETE_FLAG = false "
                      + "and p.PRODUCT_CODE = '" + productCode + "' ";

    ResultSet rs = da.getResultSet(prodcutSql);
    if(rs.next()){
        cnt = rs.getInt("CNT");
    }
    
    // 商品が存在する時のみ情報を取得する
    if(cnt > 0){
    
        // 商品情報取得
        prodcutSql = "select distinct p.PRODUCT_CODE, p.PRODUCT_NAME "
                   + "from PRODUCTS p "
                   + "where p.DELETE_FLAG = false "
                   + "and p.PRODUCT_CODE = '" + productCode + "' ";

        rs = da.getResultSet(prodcutSql);

        // Json生成
        while(rs.next()){
            JsonObjB.add("productCode", rs.getString("PRODUCT_CODE"));
            JsonObjB.add("productName", rs.getString("PRODUCT_NAME"));
        }

        // カラーコード
        String colorSql = "select p.COLOR_CODE, c.COLOR "
                + "from PRODUCTS p, COLORS c "
                + "where p.COLOR_CODE = c.COLOR_CODE "
                + "and p.DELETE_FLAG = false "
                + "and p.PRODUCT_CODE = '" + productCode + "' ";

        rs = da.getResultSet(colorSql);

        // Json生成（カラーコード）
        while(rs.next()){
            colorArrayB.add(Json.createObjectBuilder().add("colorCode", rs.getString("COLOR_CODE"))
                                                     .add("color", rs.getString("COLOR")).build());
        }    
        JsonObjB.add("colors", colorArrayB);
    }else{
        // 空データを送信
        JsonObjB.add("productCode", "");
        JsonObjB.add("productName", "");
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