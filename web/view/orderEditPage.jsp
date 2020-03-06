<%-- 
    Document   : orderEditPage
    Created on : 2020/01/08, 17:05:34
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess, java.text.NumberFormat, java.net.URLDecoder, java.io.*, javax.json.*" %>
<%@include file="../service/bootstrap.jsp" %>
<%@include file="../service/sessionCheck.jsp" %>
<%@include file="../service/tabHeder.jsp" %>
<%!
    // 関数
    String detailHtmlCreate(Boolean detailDeleteFlg, String productCode, String detailCode, String productName, String colorCode, int stock, int orderPrice, int orderCount, int subtotal) throws Exception{
        // ナンバーフォーマット
        NumberFormat nfCur = NumberFormat.getCurrencyInstance();  
        
        // カラーコード用
        DatabeseAccess colorDa = new DatabeseAccess();
        colorDa.open();
    
        // カラーコードプルダウン生成
        String colorCdSql = "select p.COLOR_CODE, c.COLOR "
                + "from PRODUCTS p, COLORS c "
                + "where p.COLOR_CODE = c.COLOR_CODE "
                + "and p.DELETE_FLAG = false "
                + "and p.PRODUCT_CODE = '" + productCode + "' ";

        ResultSet colorCdRs = colorDa.getResultSet(colorCdSql);

        // プルダウン生成
        String colorPulldown = "<select name=\"color\" class=\"form-control-sm colorPull\"> ";
        colorPulldown += "<option value=\"\" selected>選択</option>";                    
        while(colorCdRs.next()){
            colorPulldown += "<option value=\"" + colorCdRs.getString("COLOR_CODE") + "\" ";
            if(colorCode.equals(colorCdRs.getString("COLOR_CODE")) || colorCode.equals(colorCdRs.getString("COLOR"))){
                colorPulldown += "selected "; // 一致するものがあれば選択状態にする
            }
            colorPulldown += ">" + colorCdRs.getString("COLOR") + "</option>";                                        
        }
        colorPulldown += "</select>";

        // 削除フラグチェックボックス
        String delCheckBox = "<input type=\"checkbox\" class=\"form-control form-control-sm deleteCheck\" id=\"proDel\" ";
        if(detailDeleteFlg){
            delCheckBox += "checked=\"checked\" ";
        }
        delCheckBox += ">";

        // テーブル用HTMLを作成する
        String detailHTML = "<tr>" 
            + "<td>" + delCheckBox + "</td>"
            + "<td>" + productCode + "<input type=\"hidden\" value=\""+ detailCode + "\"></td>"
            + "<td>"+ productName + "</td>"
            + "<td>"+ colorPulldown + "</td>"
            + "<td>"+ stock + "</td>"
            + "<td class=\"text-right\">"+ nfCur.format(orderPrice) + "</td>"
            + "<td><input type=\"text\" class=\"form-control form-control-sm productCount\" value=\"" + orderCount + "\"></td>"
            + "<td class=\"text-right\">"+ nfCur.format(subtotal) + "</td>"
            + "</tr>";            

        colorDa.close();

        return detailHTML;
    }
%>    
<%
    
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    // ナンバーフォーマット
    NumberFormat nfCur = NumberFormat.getCurrencyInstance();  
    
    // ヘッダ項目
    String departmentCode = "";
    String departmentName = "";
    String orderUserCode = "";
    String orderUserName = "";
    String supplierCode = "";
    String supplierName = "";
    String deliveryDate = "";
    
    String taxSt = nfCur.format(0);
    String totalSt = nfCur.format(0);
    
    double tax = 0;
    int taxSum = 0;
    int total = 0;
    
    // 明細部
    String detailHTML = "";
    
    // ボタンコントロール
    String buttonHTML = "";
    
    // リクエストパラメータ文字コード設定
    request.setCharacterEncoding("UTF-8");
    
    // 受注番号の取得
    String orderCode = (String) request.getParameter("orderCode");        
    if(orderCode == null || orderCode.equals("")){
        // 新規登録
        orderCode = "";
        // 受注番号：空白、部署・受注者はログインユーザの情報を表示
        orderUserCode = userid;
        orderUserName = username;
        departmentCode =  (String) session.getAttribute("DepartmentCode");
        
        // 部署名取得
        String deptSql = "select DEPARTMENT_NAME from DEPARTMENTS where DELETE_FLAG = 0 and DEPARTMENT_CODE = '" + departmentCode + "'";
        ResultSet rs = da.getResultSet(deptSql);
        while(rs.next()){
            departmentName = rs.getString("DEPARTMENT_NAME");
        }

        // 登録ボタン表示
        buttonHTML += "<div class=\"col-auto\"> "
                    + "<input type=\"button\" class=\"btn btn-secondary\" id=\"insertButton\" value=\"登録\"> "
                    + "</div>";     
        
        // 税率マスタから現在日付の税率を取得
        String taxSql = "select TAX from TAXS where TAX_START <= CURDATE()  order by TAX_START";
        rs = da.getResultSet(taxSql);
        while(rs.next()){
            tax = rs.getInt("TAX")/100.0;
        }


    }else{
        // 変更 OR 削除
        // 受注番号に紐づくユーザ情報、受注情報の取得
        String orderSql  = "select o.ORDER_CODE, o.ORDER_DATE, DATE_FORMAT(o.DELIVERY_DATE, '%Y/%m/%d') DELIVERY_DATE, o.SUPPLIER_CODE, s.SUPPLIER_NAME, o.DEPARTMENT_CODE, d.DEPARTMENT_NAME, o.USER_CODE, u.USER_NAME ";
               orderSql += "from ORDERS o, SUPPLIERS s, USERS u, DEPARTMENTS d ";
               orderSql += "where o.SUPPLIER_CODE = s.SUPPLIER_CODE ";
               orderSql += "and o.DEPARTMENT_CODE = d.DEPARTMENT_CODE ";
               orderSql += "and o.USER_CODE = u.USER_CODE ";
               // システム管理者は論理削除された明細も参照可能               
               if(!sysFlg){
                   orderSql += "and o.DELETE_FLAG = false ";
                }
                orderSql +=  "and o.ORDER_CODE = '" + orderCode + "' ";
        
        ResultSet rs = da.getResultSet(orderSql);
        
        if(rs.next()){
            deliveryDate   = rs.getString("DELIVERY_DATE");
            supplierCode   = rs.getString("SUPPLIER_CODE");
            supplierName   = rs.getString("SUPPLIER_NAME");
            departmentCode = rs.getString("DEPARTMENT_CODE");
            departmentName = rs.getString("DEPARTMENT_NAME");
            orderUserCode  = rs.getString("USER_CODE");
            orderUserName  = rs.getString("USER_NAME");

            // 税率マスタから受注日の税率を取得
            String taxSql = "select TAX from TAXS where TAX_START <= '" + deliveryDate + "' order by TAX_START";
            ResultSet taxRs = da.getResultSet(taxSql);
            while(taxRs.next()){
                tax = taxRs.getInt("TAX")/100.0;
            }
            
        }else{
            // エラー処理させる
        }

        String detailSql  = "select d.DELETE_FLAG, o.ORDER_CODE, d.DETAIL_CODE, d.PRODUCT_CODE, p.PRODUCT_NAME, d.COLOR_CODE, p.STOCK, p.ALLOCATION, d.ORDER_COUNT, d.ORDER_PRICE ";
               detailSql += "from ORDERS o, DETAILS d, PRODUCTS p ";
               detailSql += "where o.ORDER_CODE = d.ORDER_CODE ";
               detailSql += "and d.PRODUCT_CODE = p.PRODUCT_CODE ";
               detailSql += "and d.COLOR_CODE = p.COLOR_CODE ";
               // システム管理者は論理削除された明細も参照可能               
               if(!sysFlg){
                   detailSql += "and d.DELETE_FLAG = false ";
               }
               detailSql += "and o.ORDER_CODE = '" + orderCode + "' ";
               detailSql += "order by o.ORDER_CODE, d.DETAIL_CODE ";
        
        rs = da.getResultSet(detailSql);
        
        while(rs.next()){

            // 明細項目
            Boolean detailDeleteFlg = rs.getBoolean("DELETE_FLAG");
            String detailCode = rs.getString("DETAIL_CODE");
            String productCode = rs.getString("PRODUCT_CODE");
            String productName = rs.getString("PRODUCT_NAME");
            String colorCode = rs.getString("COLOR_CODE");
            int stock = rs.getInt("STOCK") - rs.getInt("ALLOCATION");
            int orderPrice = rs.getInt("ORDER_PRICE");
            int orderCount = rs.getInt("ORDER_COUNT");
            int subtotal = orderPrice * orderCount;
            
            // 合計金額計算(削除フラグONの金額は計算しない)
            if(!detailDeleteFlg){
                taxSum += subtotal * tax;
                total += subtotal + subtotal * tax;
            }
            
            // テーブル用HTMLを作成する
            detailHTML += detailHtmlCreate(detailDeleteFlg, productCode,detailCode,productName,colorCode,stock,orderPrice,orderCount,subtotal);

        }
        
        // 変更・削除ボタン表示
        buttonHTML += "<div class=\"col-auto\"> "
                    + "<input type=\"button\" class=\"btn btn-secondary\" id=\"updateButton\" value=\"変更\"> "
                    + "</div> "
                    + "<div class=\"col-auto\"> "
                    + "<input type=\"button\" class=\"btn btn-secondary\" id=\"deleteButton\" value=\"削除\"> "
                    + "</div>";
    }
    
    // クッキーからの情報を表示（新規追加したが検索などの画面遷移をしたとき用）
    // クッキーを保存するタイミングは商品検索ボタン、取引先検索ボタン押下時
    Cookie[] cookies = request.getCookies();
    for (Cookie cookie : cookies) {

        // 商品新規行
        if(cookie.getName().equals("newProRow")){
            
            // クッキーに情報がある場合は最優先させるため初期化
            detailHTML = "";
            taxSum = 0;
            total = 0;
            
            // エンコードされて渡されるのでデコード処理
            String decodedResult = URLDecoder.decode(cookie.getValue(), "UTF-8");
            
            JsonReader reader = Json.createReader(new StringReader(decodedResult));
            // Jsonの配列を取得
            JsonArray jsonArray = reader.readArray();            
            for(int i=0; i<jsonArray.size(); i++){
                JsonObject jsonObj = jsonArray.getJsonObject(i);
                
                Boolean detailDeleteFlg = jsonObj.getBoolean("deleteFlg", false);
                int subtotal = jsonObj.getInt("subtotal",0);

                // 合計金額計算(削除フラグONの金額は計算しない)
                if(!detailDeleteFlg){
                    taxSum += subtotal * tax;
                    total += subtotal + subtotal * tax;
                }

                // テーブル用HTMLを作成する
                detailHTML += detailHtmlCreate(detailDeleteFlg,
                                               jsonObj.getString("productCode",""),
                                               String.valueOf(jsonObj.getInt("detailCode",0)),
                                               jsonObj.getString("productName",""),
                                               jsonObj.getString("colorCode",""),
                                               jsonObj.getInt("stock",0),
                                               jsonObj.getInt("price",0),
                                               jsonObj.getInt("productCount",0),
                                               subtotal);
            }
        }

        // 取引先コード
        if(cookie.getName().equals("newSupplier")){
            // エンコードされて渡されるのでデコード処理
            String decodedResult = URLDecoder.decode(cookie.getValue(), "UTF-8");
            supplierCode = decodedResult;
        }        
        // 取引先名
        if(cookie.getName().equals("newSupplierName")){
            // エンコードされて渡されるのでデコード処理
            String decodedResult = URLDecoder.decode(cookie.getValue(), "UTF-8");
            supplierName = decodedResult;
        }

        // 納品日
        if(cookie.getName().equals("newDeliveryDate")){
            // エンコードされて渡されるのでデコード処理
            String decodedResult = URLDecoder.decode(cookie.getValue(), "UTF-8");
            deliveryDate = decodedResult;
        }
    }

    // 処理終わればクッキー削除
    Cookie cookie = new Cookie("newProRow", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);
    
    cookie = new Cookie("newSupplier", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);
    
    cookie = new Cookie("newSupplierName", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);
    
    cookie = new Cookie("newDeliveryDate", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);

    // 取引先検索画面から戻ってきたとき
    String supplierSearchCode = (String) request.getParameter("supplierCode");
    if(supplierSearchCode != null){

        String supplierSearchName = (String) request.getParameter("supplierName");
        
        // 取引先コードと取引先名を設定する。
        supplierCode = supplierSearchCode;
        supplierName = supplierSearchName;

    }
    
    // 商品検索画面から戻ってきたとき
    String productSearchCode = (String) request.getParameter("productCode");
    if(productSearchCode != null){
        // 商品検索画面から戻ってきたとき
        Boolean wkDelFlg = false;
        String wkDetailCode = "0";
        String productSearchName  = (String) request.getParameter("productName");
        String productSearchColor = (String) request.getParameter("color");
        int productSearchStock = Integer.parseInt(request.getParameter("stock"));
        int productSearchPrice = Integer.parseInt(request.getParameter("price"));
        
        // テーブル用HTMLを作成する
        detailHTML += detailHtmlCreate(wkDelFlg, productSearchCode, wkDetailCode, productSearchName,productSearchColor,productSearchStock,productSearchPrice,0,0);
        
    }
    
    // 合計値をフォーマットして設定
    taxSt = nfCur.format(taxSum);
    totalSt = nfCur.format(total);


    
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
        
        <!-- タブヘッダー部 -->
        <%= tabHederHTML %>
        
	<h2 class="text-center mt-3">受注明細</h2>
        <div class="container-fluid">
        <form class="mx-5">
            
            <!-- 受注ヘッダー部 -->
            <div class="row form-group" >
		<div class="col-md-4">
                    <label for="orderCode" class="col-form-label">受注番号</label>
                    <input type="text" class="form-control" id="orderCode" value="<%= orderCode %>" readonly>
                </div>            

    		<div class="col-md-4">
                    <label for="departmentName" class="col-form-label">部署</label>
                    <input type="text" class="form-control" id="departmentName" value="<%= departmentName %>" readonly>
                    <input type="hidden" class="form-control" id="departmentCode" value="<%= departmentCode %>">
                </div>            

		<div class="col-md-4">
                    <label for="orderUserName" class="col-form-label">受注者</label>
                    <input type="text" class="form-control" id="orderUserName" value="<%= orderUserName %>" readonly>
                    <input type="hidden" class="form-control" id="orderUserCode" value="<%= orderUserCode %>">
                </div>            
            </div>

            <div class="row form-group" >
                <div class="col-md-3">
                    <label for="supplierCode" class="col-form-label">取引先コード</label>                   
                    <input type="text" class="form-control" id="supplierCode" placeholder="取引先コードを入力" value="<%= supplierCode %>"> 
                </div>
                <div class="col-md-1 d-flex align-items-end">
                    <input type="button" class="btn btn-secondary" id="searchSupplierButton" value="検索"> 
                </div>
                <div class="col-md-4">
                    <label for="supplierName" class="col-form-label">取引先名</label>                   
                    <input type="text" class="form-control" id="supplierName" value="<%= supplierName %>" readonly>
                </div>

                <div class="col-md-4">
                    <label for="deliveryDate" class="col-form-label">納品日</label>
                    <input type="text" class="form-control" id="deliveryDate" placeholder="YYYY/MM/DD" value="<%= deliveryDate %>">
		</div>
            </div>

            <div class="row form-group" >
                <!-- ボタンの表示 -->
                <%= buttonHTML %>
            </div>

            <!-- 受注明細タイトル -->
            <table class="table table-striped table-bordered" id="orderDetailTable" >
                <thead class="thead-dark">
                <tr class=\bg-dark">
                    <th scope="col" class="text-white">商品削除</th>
                    <th scope="col" class="text-white">商品コード</th>
                    <th scope="col" class="text-white">商品名</th>
                    <th scope="col" class="text-white">カラー</th>
                    <th scope="col" class="text-white">在庫</th>
                    <th scope="col" class="text-white">単価</th>
                    <th scope="col" class="text-white">個数</th>
                    <th scope="col" class="text-white">小計</th>
                </tr>
                </thread>

                <tbody>
                <!-- 受注明細部 -->
                <%= detailHTML %>
                
                <!-- 明細部サンプル
                <tr>
                    <td scope="row"><input type="checkbox"  class="form-control form-control-sm" id="proDel"></td>
                    <td>ZZZZZZZZZZ</td>  
                    <td>テスト商品A</td>
                    <td><select name="color" class="form-control-sm">
                        <option value="color1">白</option>
                        <option value="color1">黒</option>
                        <option value="color1">赤</option>
		    </select></td>
                    <td>999</td>
                    <td class="text-right">￥99,999</td>
                    <td><input type="text" class="form-control form-control-sm" id="kosu" placeholder="99"></td>
                    <td class="text-right">￥99,999</td>
                </tr>
                </div>
                -->
                
                <!-- 新規追加行 -->
                <tr class="table-light">
                    <td scope="row"><input type="button" class="btn btn-secondary" id="searchProductBt" value="検索追加"></td>
                    <td><input type="text" class="form-control" id="addProductCode" placeholder="追加する商品コードを入力" value=""></td>  
                    <td><input type="button" class="btn btn-secondary" id="addProductBt" value="商品追加"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                
                <!-- 受注フッター部 -->
                <tr class="table-light">
                    <td scope="row"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td class="text-right">税 (<%= (int)(tax*100) %>\%)</td>  
                    <td class="text-right" id="tax"><%= taxSt %></td>
                </tr>
                <tr class="table-light">
                    <td scope="row"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td class="text-right">合計</td>  
                    <td class="text-right" id="total"><%= totalSt %></td>
                </tr>
                </tbody>
            </table>
                
            <!-- 税率 -->
            <input type="hidden" id="taxHidden" value="<%= tax %>">

        </form>
        </div>
        
        <!-- Bootstrap JavaScript -->
        <%= bsJs %>
        <!-- JavaScript -->
        <script src='../js/orderEdit.js'></script> 
    </body>
</html>
