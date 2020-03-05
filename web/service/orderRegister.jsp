<%-- 
    Document   : orderRegister
    Created on : 2020/01/20, 14:11:18
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.io.*, java.util.*, java.net.URLDecoder"%>
<%@page import="javax.json.*, javax.json.stream.JsonParser"%>
<%@include file="../service/bootstrap.jsp" %>
<%
    // リクエストパラメータ受け取り
    String processRequest = URLDecoder.decode(request.getParameter("processRequest"),"UTF-8"); //処理パラメータ
    String orderCode = URLDecoder.decode(request.getParameter("orderCode"),"UTF-8");
    String supplierCode = URLDecoder.decode(request.getParameter("supplierCode"),"UTF-8");
    String deliveryDate = URLDecoder.decode(request.getParameter("deliveryDate"),"UTF-8");
    String departmentCode = URLDecoder.decode(request.getParameter("departmentCode"),"UTF-8");
    String orderUserCode = URLDecoder.decode(request.getParameter("orderUserCode"),"UTF-8");
    String order = URLDecoder.decode(request.getParameter("parameterJson"),"UTF-8"); // 受注明細情報
    
    

    System.out.println("orderCode:"+orderCode);
    System.out.println("supplierCode:"+supplierCode);
    System.out.println("deliveryDate:"+deliveryDate);
    System.out.println("departmentCode:"+departmentCode);
    System.out.println("orderUserCode:"+orderUserCode);
    System.out.println("orderList:"+order);
    
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    if(processRequest.equals("insert")){

        String sql = "SELECT MAX(ORDER_CODE)+1 NEW_ORDER_CODE FROM ORDERS";
        ResultSet rs = da.getResultSet(sql);
        while(rs.next()){
            orderCode = rs.getString("NEW_ORDER_CODE");
        }
        
        // ヘッダ登録 税率マスタをパラメータで受け取る
        sql = "INSERT INTO ORDERS(ORDER_CODE, ORDER_DATE, DELIVERY_DATE, DELETE_FLAG, SUPPLIER_CODE, TAX_CODE, DEPARTMENT_CODE, USER_CODE) "
                        + "VALUES("+ orderCode +", CURDATE(), '"+ deliveryDate +"', false, '"+ supplierCode +"', 1, '"+ departmentCode +"', '"+ orderUserCode +"')";
        
        da.execute(sql);

        // 明細登録
        String jsonKey = ""; // JSON形式のキー値を格納する変数
        boolean delFlg = true;
        int detailCode = 1;
        String productCode = "";
        String colorCode = "";
        int orderCount = 0;
        int orderPrice = 0;

        // JSON形式のパラメータをパース
        JsonParser parser = Json.createParser(new StringReader(order));
        while (parser.hasNext()) {
            JsonParser.Event event = parser.next();
            switch(event) {
                case START_ARRAY: // 処理不要のため何もしない
                case END_ARRAY:
                case VALUE_NULL:
                    break;

                case START_OBJECT: // 商品情報の始まりなので変数を初期化
                    delFlg = true;
                    productCode = "";
                    colorCode = "";
                    orderCount = 0;
                    orderPrice = 0;                    
                    break;

                case KEY_NAME: // キー項目を保存
                    jsonKey = parser.getString();
                    break;
                    
                case VALUE_TRUE:
                    delFlg = true;   // 削除フラグを設定
                    break;
                case VALUE_FALSE:
                    delFlg = false;  // 削除フラグを設定
                    break;
                    
                case VALUE_STRING:
                case VALUE_NUMBER:
                    // キー値に対応した変数に値を格納
                    if(jsonKey.equals("productCode")){
                        productCode = parser.getString();                        
                    }else if(jsonKey.equals("colorCode")){
                        colorCode = parser.getString();                        
                    }else if(jsonKey.equals("productCount")){
                        orderCount = parser.getInt();
                    }else if(jsonKey.equals("price")){
                        orderPrice = parser.getInt();                                            
                    }
                    break;
                case END_OBJECT: // 商品情報の終わりなのでINSERT処理を行う
                    if(!delFlg){
                        sql = "INSERT INTO DETAILS(ORDER_CODE, DETAIL_CODE, ORDER_COUNT, ORDER_PRICE, DELETE_FLAG, PRODUCT_CODE, COLOR_CODE) "
                                         + "VALUES("+ orderCode +", "+ detailCode +", "+ orderCount +", "+ orderPrice +", false, '"+ productCode +"', '"+ colorCode +"')";
                        System.out.println(sql);
                        da.execute(sql);
                        detailCode++;                        
                    }
                    break;
           }        
        }
        
        da.commit();
        
    }else if(processRequest.equals("update")){

        // ヘッダ更新 
        String sql = "UPDATE ORDERS SET DELIVERY_DATE = '" + deliveryDate + "' "
                   + "WHERE  ORDER_CODE = '"+ orderCode +"' ";
        
        da.execute(sql);

        // 明細更新
        String jsonKey = ""; // JSON形式のキー値を格納する変数
        boolean delFlg = true;
        int detailCode = 1;
        String productCode = "";
        String colorCode = "";
        int orderCount = 0;
        int orderPrice = 0;

        // JSON形式のパラメータをパース
        JsonParser parser = Json.createParser(new StringReader(order));
        while (parser.hasNext()) {
            JsonParser.Event event = parser.next();
            switch(event) {
                case START_ARRAY: // 処理不要のため何もしない
                case END_ARRAY:
                case VALUE_NULL:
                    break;

                case START_OBJECT: // 商品情報の始まりなので変数を初期化
                    delFlg = true;
                    productCode = "";
                    colorCode = "";
                    orderCount = 0;
                    orderPrice = 0;                    
                    break;

                case KEY_NAME: // キー項目を保存
                    jsonKey = parser.getString();
                    break;
                    
                case VALUE_TRUE:
                    delFlg = true;   // 削除フラグを設定
                    break;
                case VALUE_FALSE:
                    delFlg = false;  // 削除フラグを設定
                    break;
                    
                case VALUE_STRING:
                case VALUE_NUMBER:
                    // キー値に対応した変数に値を格納
                    if(jsonKey.equals("productCode")){
                        productCode = parser.getString();                        
                    }else if(jsonKey.equals("colorCode")){
                        colorCode = parser.getString();                        
                    }else if(jsonKey.equals("productCount")){
                        orderCount = parser.getInt();
                    }else if(jsonKey.equals("price")){
                        orderPrice = parser.getInt();                                            
                    }else if(jsonKey.equals("detailCode")){
                        detailCode = parser.getInt();
                    }
                    break;
                case END_OBJECT: // 商品情報の終わりなのでUPDATE処理を行う
                    sql = "UPDATE DETAILS "
                        + "SET ORDER_COUNT = "+ orderCount +", "
                        +     "ORDER_PRICE = "+ orderPrice +", "
                        +     "DELETE_FLAG = "+ delFlg +", "
                        +     "PRODUCT_CODE = '"+ productCode +"', "
                        +     "COLOR_CODE  = '"+ colorCode +"'"
                        + "WHERE ORDER_CODE = '"+ orderCode + "' "
                        +   "AND DETAIL_CODE = '"+ detailCode +"'";
                    da.execute(sql);
                    break;
           }
        }
        
        da.commit();
        
    }else if(processRequest.equals("delete")){
        
        // 削除処理の場合は、受注のヘッダと明細の削除フラグをTRUEに更新（論理削除）
        String sql = "UPDATE ORDERS SET DELETE_FLAG = true "
           + "WHERE  ORDER_CODE = '"+ orderCode +"' ";        
        da.execute(sql);

        sql = "UPDATE DETAILS SET DELETE_FLAG = true "
           + "WHERE  ORDER_CODE = '"+ orderCode +"' ";        
        da.execute(sql);

        da.commit();
        
    }

    // DBクローズ
    da.close();
    
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <!-- Bootstrap CSS -->
        <%= bsCss %>
        <title>受発注システム</title>
    </head>
    <body>
        <input type="hidden" id="orderCode" value="<%= orderCode %>">

        <!-- Bootstrap JavaScript -->
        <%= bsJs %>
        <!-- JavaScript -->
        <script src='../js/orderRegister.js'></script>         
    </body>
</html>
