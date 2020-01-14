<%-- 
    Document   : orderEditPage
    Created on : 2020/01/08, 17:05:34
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess, java.text.NumberFormat" %>
<%@include file="../service/bootstrap.jsp" %>
<%@include file="../service/sessionCheck.jsp" %>
<%@include file="../service/tabHeder.jsp" %>
<%
    
    // DB接続    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    // ヘッダ項目
    String deptNo = "";
    String orderUserName = "";
    String supplierCode = "";
    String supplierName = "";
    String deliveryDate = "";
    
    int tax = 0;
    int total = 0;
    
    // ナンバーフォーマット
    NumberFormat nfCur = NumberFormat.getCurrencyInstance();  
    
    // 明細部
    String detailHTML = "";
    
    // ボタンコントロール
    String buttonHTML = "";
    
    // 受注番号の取得
    String orderNo = (String) request.getParameter("orderNo");        
    if(orderNo == null || orderNo == ""){
        // 新規登録
        orderNo = "";
        // 受注番号：空白、部署・受注者はログインユーザの情報を表示
        orderUserName = username;
        
        
        // 登録ボタン表示
        buttonHTML += "<div class=\"col-auto\"> "
                    + "<input type=\"button\" class=\"btn btn-secondary\" id=\"insertButton\" value=\"登録\"> "
                    + "</div>";        
    }else{
        // 変更 OR 削除
        // 受注番号に紐づくユーザ情報、受注情報の取得
        String orderSql = "select o.ORDER_CODE, o.ORDER_DATE, DATE_FORMAT(o.DELIVERY_DATE, '%Y/%m/%d') DELIVERY_DATE, o.SUPPLIER_CODE, s.SUPPLIER_NAME "
                        + "from ORDERS o, SUPPLIERS s "
                        + "where o.SUPPLIER_CODE = s.SUPPLIER_CODE "
                        + "and o.DELETE_FLAG = false "
                        + "and o.ORDER_CODE = '" + orderNo + "' ";
        
        ResultSet rs = da.getResultSet(orderSql);
        
        if(rs.next()){
            deliveryDate = rs.getString("DELIVERY_DATE");
            supplierCode = rs.getString("SUPPLIER_CODE");
            supplierName = rs.getString("SUPPLIER_NAME");

            // 税率マスタから受注日の税率を取得
        }else{
            // エラー処理させる
        }

        String detailSql = "select o.ORDER_CODE, d.DETAIL_CODE, d.PRODUCT_CODE, p.PRODUCT_NAME, d.COLOR_CODE, p.STOCK, p.ALLOCATION, d.PRODUCT_COUNT "
                         + "from ORDERS o, DETAILS d, PRODUCTS p "
                         + "where o.ORDER_CODE = d.ORDER_CODE "
                         + "and d.PRODUCT_CODE = p.PRODUCT_CODE "
                         + "and d.COLOR_CODE = p.COLOR_CODE "
                         + "and d.DELETE_FLAG = false "
                         + "and o.ORDER_CODE = '" + orderNo + "' "
                         + "order by o.ORDER_CODE, d.DETAIL_CODE ";

        rs = da.getResultSet(detailSql);
        
        if(rs.next()){

            // 明細項目
            String detailDeleteFlg = "";
            String detailCode = rs.getString("DETAIL_CODE");
            String productCode = rs.getString("PRODUCT_CODE");
            String productName = rs.getString("PRODUCT_NAME");
            String color_code = rs.getString("COLOR_CODE");
            int stock = rs.getInt("STOCK") - rs.getInt("ALLOCATION");
            int orderPrice = 100;
            int productCount = rs.getInt("PRODUCT_COUNT");
            int subtotal = orderPrice * productCount;
            
            // カラーコードプルダウン生成
            String colorCdSql = "select p.COLOR_CODE, c.COLOR "
                    + "from PRODUCTS p, COLORS c "
                    + "where p.COLOR_CODE = c.COLOR_CODE "
                    + "and p.DELETE_FLAG = false "
                    + "and p.PRODUCT_CODE = '" + productCode + "' ";
            
            ResultSet colorCdRs = da.getResultSet(colorCdSql);

            String colorPulldown = "<select name=\"color\" class=\"form-control-sm\"> ";
            colorPulldown += "<option value=\"\" selected>選択</option>";                    
            if(colorCdRs.next()){
                if(color_code.equals(colorCdRs.getString("COLOR_CODE"))){
                    colorPulldown += "<option value=\"" + colorCdRs.getString("COLOR_CODE") + "\" selected>" + colorCdRs.getString("COLOR") + "</option>";                    
                }else{
                    colorPulldown += "<option value=\"" + colorCdRs.getString("COLOR_CODE") + "\">" + colorCdRs.getString("COLOR") + "</option>";                                        
                }
            }
            colorPulldown += "</select>";
            

            // テーブル用HTMLを作成する
            detailHTML = "<tr>" 
                + "<td scope=\"row\"><input type=\"checkbox\"  class=\"form-control form-control-sm\" id=\"proDel\"></td>"
                + "<td>" + productCode + "</td>"
                + "<td>"+ productName + "</td>"
                + "<td>"+ colorPulldown + "</td>"
                + "<td>"+ stock + "</td>"
                + "<td class=\"text-right\">"+ nfCur.format(orderPrice) + "</td>"
                + "<td><input type=\"text\" class=\"form-control form-control-sm\" id=\"kosu\" placeholder=\"99\" value=\"" + productCount + "\"></td>"
                + "<td class=\"text-right\">"+ nfCur.format(subtotal) + "</td>"
                + "</tr>";            
        }

        // 変更・削除ボタン表示
        buttonHTML += "<div class=\"col-auto\"> "
                    + "<input type=\"button\" class=\"btn btn-secondary\" id=\"updateButton\" value=\"変更\"> "
                    + "</div> "
                    + "<div class=\"col-auto\"> "
                    + "<input type=\"button\" class=\"btn btn-secondary\" id=\"deleteButton\" value=\"削除\"> "
                    + "</div>";        

    }
    
    // 商品コードの取得
    String productSearchCode = (String) request.getParameter("productCode");
    if(productSearchCode != null){
        // 商品検索画面から戻ってきたとき
        String colorSearchCode = (String) request.getParameter("colorSearchCode");
    }

    // DBクローズ
    da.close();

%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
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
                    <input type="text" class="form-control" id="orderCode" value="<%= orderNo %>" readonly>
                </div>            

    		<div class="col-md-4">
                    <label for="departmentCode" class="col-form-label">部署</label>
                    <input type="text" class="form-control" id="departmentCode" value="第１営業部" readonly>
                </div>            

		<div class="col-md-4">
                    <label for="orderUserCode" class="col-form-label">受注者</label>
                    <input type="text" class="form-control" id="orderUserCode" value="<%= orderUserName %>" readonly>
                </div>            
            </div>

            <div class="row form-group" >
                <div class="col-md-3">
                    <label for="supplierCode" class="col-form-label">取引先コード</label>                   
                    <input type="text" class="form-control" id="supplierCode" placeholder="取引先コードを入力" value="<%= supplierCode %>"> 
                </div>
                <div class="col-md-1 d-flex align-items-end">
                    <input type="button" class="btn btn-secondary" id="supplierbutton" value="検索"> 
                </div>
                <div class="col-md-4 d-flex align-items-end">
                    <input type="text" class="form-control" id="supplierName" placeholder="取引先名" value="<%= supplierName %>" readonly>
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
            <table class="table table-striped table-bordered" >
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
                -->
                
                <!-- 受注明細部 -->
                <%= detailHTML %>
                
                <!-- 新規追加行 -->
                <tr class="table-light">
                    <td scope="row"><input type="button" class="btn btn-secondary" id="supplierbutton" value="検索追加"></td>
                    <td><input type="text" class="form-control" id="supplierCode" placeholder="追加する商品コードを入力" value=""></td>  
                    <td><input type="button" class="btn btn-secondary" id="supplierbutton" value="商品追加"></td>
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
                    <td class="text-right">税</td>  
                    <td class="text-right">￥9,999</td>
                </tr>
                <tr class="table-light">
                    <td scope="row"></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td class="text-right">合計</td>  
                    <td class="text-right">￥9,999,999</td>
                </tr>
                </tbody>
            </table>

        </form>
        </div>
        
        <%= bsJs %>
    </body>
</html>
