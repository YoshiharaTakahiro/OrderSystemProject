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
<%!
    // 指定された商品コードとカラーの在庫のチェックを行う
    Boolean stockCheck(String productCode, String colorCode, int orderCount, DatabeseAccess da) throws Exception{
        // 在庫確認
        int stock = 0;
        int allocation = 0;
        String sql = "SELECT STOCK, ALLOCATION FROM PRODUCTS WHERE PRODUCT_CODE = '"+ productCode +"' AND COLOR_CODE = '"+ colorCode +"' FOR UPDATE"; // 商品情報ロック
        ResultSet rs = da.getResultSet(sql);
        if(rs.next()){
            stock = rs.getInt("STOCK");
            allocation = rs.getInt("ALLOCATION");
        }
        
        // 在庫と注文数と引当数チェック
        Boolean stockOK = false;
        if(stock >= (allocation + orderCount)){
            stockOK = true;
        }else{
            stockOK = false;
        }
        return stockOK;
    }
    
    // 新規行登録処理
    void newDetailsInsert(String orderCode, int detailCode, int orderCount, int orderPrice, String productCode, String colorCode, DatabeseAccess da) throws Exception{
        // 明細登録
        String sql = "INSERT INTO DETAILS(ORDER_CODE, DETAIL_CODE, ORDER_COUNT, ORDER_PRICE, DELETE_FLAG, PRODUCT_CODE, COLOR_CODE) "
                         + "VALUES("+ orderCode +", "+ detailCode +", "+ orderCount +", "+ orderPrice +", false, '"+ productCode +"', '"+ colorCode +"')";
        da.execute(sql);

        // 在庫引当処理
        sql = "UPDATE PRODUCTS SET ALLOCATION = ALLOCATION + "+ orderCount +" "
            + "WHERE  PRODUCT_CODE = '"+ productCode +"' AND COLOR_CODE = '"+ colorCode +"'";
        da.execute(sql);    
    }
    
    // 引当済みキャンセル処理
    void undoAllocation(String orderCode, DatabeseAccess da) throws Exception{
    
        DatabeseAccess detailDa = new DatabeseAccess();
        detailDa.open();
    
        // 変更前明細の引当数を元に戻す
        String sql = "SELECT PRODUCT_CODE, COLOR_CODE, ORDER_COUNT FROM DETAILS "
            + "WHERE ORDER_CODE = '"+ orderCode +"' "
            + "AND   DELETE_FLAG = false "
            + "ORDER BY ORDER_CODE, DETAIL_CODE";

        ResultSet rs = detailDa.getResultSet(sql);
        while(rs.next()){
            String beforeProductCode = rs.getString("PRODUCT_CODE");
            int beforeColorCode = rs.getInt("COLOR_CODE");
            int beforeOrderCount = rs.getInt("ORDER_COUNT");
            
            // 商品ごとの引当済みを更新
            sql = "UPDATE PRODUCTS SET ALLOCATION = ALLOCATION - " + beforeOrderCount + " "
                + "WHERE PRODUCT_CODE = '"+ beforeProductCode +"' "
                + "AND   COLOR_CODE = '"+ beforeColorCode +"' ";
            da.execute(sql);            
        }        
        detailDa.close();
    
    }
%>    
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
    
    // 正常終了時に受注明細画面に表示するメッセージ
    String successMessage = "";
    
    // 在庫チェックがNGの時に受注明細画面に表示するメッセージ
    String stockMessage = "";
    
    // エラーによりロールバックが必要になった場合のフラグ
    Boolean rollbackFlg = false;
    
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    if(processRequest.equals("insert")){

        String sql = "SELECT MAX(ORDER_CODE)+1 NEW_ORDER_CODE FROM ORDERS";
        ResultSet rs = da.getResultSet(sql);
        while(rs.next()){
            orderCode = rs.getString("NEW_ORDER_CODE");
        }
        if(orderCode == null){
            orderCode = "1"; // ORDERSテーブルが空の場合の対応            
        }
        
        // 税率マスタから現在日付の税率を取得
        int taxCode = 1;
        sql = "select TAX_CODE from TAXS where TAX_START <= CURDATE()  order by TAX_START";
        rs = da.getResultSet(sql);
        while(rs.next()){
            taxCode = rs.getInt("TAX_CODE");
        }
                
        // ヘッダ登録
        sql = "INSERT INTO ORDERS(ORDER_CODE, ORDER_DATE, DELIVERY_DATE, DELETE_FLAG, SUPPLIER_CODE, TAX_CODE, DEPARTMENT_CODE, USER_CODE) "
                        + "VALUES("+ orderCode +", CURDATE(), '"+ deliveryDate +"', false, '"+ supplierCode +"', "+ taxCode +", '"+ departmentCode +"', '"+ orderUserCode +"')";
        
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
                    if(!delFlg){ // 商品削除にチェックが入っている商品は登録しない
                        
                        // 在庫チェック
                        if(stockCheck(productCode, colorCode, orderCount, da)){
                            
                            newDetailsInsert(orderCode, detailCode, orderCount, orderPrice, productCode, colorCode, da);
                            detailCode++;  // 明細番号インクリメント
                        }else{
                            // 在庫が足らない場合はロールバックして処理終了
                            stockMessage = "在庫が引当できませんでした。\\n最新の状態で再度処理を実行してください";
                            rollbackFlg = true;
                        }                        
                    }
                    break;
           }        
        }
        
        // ロールバックか否か
        if(rollbackFlg){
            da.rollback();            
        }else{
            successMessage = "受注の新規登録が完了しました";
            da.commit();            
        }
        
    }else if(processRequest.equals("update")){

        // ヘッダ更新 
        String sql = "UPDATE ORDERS SET DELIVERY_DATE = '" + deliveryDate + "' "
                   + "WHERE  ORDER_CODE = '"+ orderCode +"' ";
        
        da.execute(sql);
                
        // 変更前明細の引当数を元に戻す
        undoAllocation(orderCode, da);

        // 明細更新
        String jsonKey = ""; // JSON形式のキー値を格納する変数
        boolean delFlg = true;
        int detailCode = 0;
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
                    detailCode = 0;
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
                    
                    if(detailCode != 0){                        

                        // 在庫と注文数と引当数チェック
                        if(stockCheck(productCode, colorCode, orderCount, da)){
                            sql = "UPDATE DETAILS "
                                + "SET ORDER_COUNT = "+ orderCount +", "
                                +     "ORDER_PRICE = "+ orderPrice +", "
                                +     "DELETE_FLAG = "+ delFlg +", "
                                +     "PRODUCT_CODE = '"+ productCode +"', "
                                +     "COLOR_CODE  = '"+ colorCode +"'"
                                + "WHERE ORDER_CODE = '"+ orderCode + "' "
                                +   "AND DETAIL_CODE = '"+ detailCode +"'";
                            da.execute(sql);
                        
                            if(!delFlg){ // 商品削除行は在庫引当行わない
                                sql = "UPDATE PRODUCTS SET ALLOCATION = ALLOCATION + "+ orderCount +" "
                                    + "WHERE  PRODUCT_CODE = '"+ productCode +"' AND COLOR_CODE = '"+ colorCode +"'";
                                da.execute(sql);
                            }

                        }else{
                            // 在庫が足らない場合はロールバックして処理終了
                            stockMessage = "在庫が引当できませんでした。最新の状態で再度処理を実行してください";
                            rollbackFlg = true;
                        }                        
                        

                    }else{
                        // 明細番号が0の行は新規追加行なのでINSERT処理を行う
                        if(!delFlg){
                            
                            // 明細番号の最大値を取得
                            sql = "SELECT MAX(DETAIL_CODE)+1 NEW_DETAIL_CODE FROM DETAILS WHERE ORDER_CODE = '"+ orderCode +"'";
                            ResultSet rs = da.getResultSet(sql);
                            if(rs.next()){
                                detailCode = rs.getInt("NEW_DETAIL_CODE");
                            }

                            // 在庫と注文数と引当数チェック
                            if(stockCheck(productCode, colorCode, orderCount, da)){                                
                                // 新規行追加
                                newDetailsInsert(orderCode, detailCode, orderCount, orderPrice, productCode, colorCode, da);
                            }else{
                                // 在庫が足らない場合はロールバックして処理終了
                                stockMessage = "在庫が引当できませんでした。\\n最新の状態で再度処理を実行してください";
                                rollbackFlg = true;
                            }                        

                        }
                    }
                    break;
           }
        }
        
        // １件でも明細が有効ならヘッダの削除フラグをFALSEに更新して有効化
        // 有効な明細が0件の場合はヘッダの削除フラグをTRUE
        Boolean hederDelFlg = false;
        sql = "SELECT COUNT(*) AS CNT FROM DETAILS "
                + "WHERE ORDER_CODE = '"+ orderCode +"' "
                + "AND DELETE_FLAG = false ";
        ResultSet rs = da.getResultSet(sql);
        if(rs.next()){
            int cnt = rs.getInt("CNT");
            if(cnt == 0){
                hederDelFlg = true;
            }
        }
        
        sql = "UPDATE ORDERS SET DELETE_FLAG = "+ hederDelFlg +" "
           + "WHERE  ORDER_CODE = '"+ orderCode +"' ";        
        da.execute(sql);
        
        // ロールバックか否か
        if(rollbackFlg){
            da.rollback();            
        }else{
            successMessage = "受注の変更処理が完了しました";
            da.commit();            
        }
        
    }else if(processRequest.equals("delete")){
        
        // 削除前明細の引当数を元に戻す
        undoAllocation(orderCode, da);
        
        // 削除処理の場合は、受注のヘッダと明細の削除フラグをTRUEに更新（論理削除）
        String sql = "UPDATE ORDERS SET DELETE_FLAG = true "
           + "WHERE  ORDER_CODE = '"+ orderCode +"' ";        
        da.execute(sql);

        sql = "UPDATE DETAILS SET DELETE_FLAG = true "
           + "WHERE  ORDER_CODE = '"+ orderCode +"' ";        
        da.execute(sql);

        successMessage = "受注の削除処理が完了しました";
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
        <input type="hidden" id="stockMessage" value="<%= stockMessage %>">
        <input type="hidden" id="successMessage" value="<%= successMessage %>">

        <!-- Bootstrap JavaScript -->
        <%= bsJs %>
        <!-- JavaScript -->
        <script src='../js/orderRegister.js'></script>         
    </body>
</html>
