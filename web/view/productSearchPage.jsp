<%-- 
    Document   : productSearchPage.jsp
    Created on : 2020/01/08
    Author     : masahiro.fujihara
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@include file="../service/bootstrap.jsp" %>
<%!
//---------------------------------------------------------------
//汎用マスタープルダウンのHTMLを作成するメソッド
// 引数：String division = 区分
//	String queryStr = 受信したクエリ
//	String optionStr = "htmlの文字列を入れる変数
// 戻値：html文
//---------------------------------------------------------------
String doPullDownMake(String division, String queryStr, String optionStr){
    String sql;
    ResultSet rs;

    DatabeseAccess da = new DatabeseAccess();
    try {
	da.open();

	//SQL文を実行する
	sql = "select DIVISION, GENERAL_CODE, GENERAL_NAME from generals where DIVISION=\"" + division + "\"";
        rs = da.getResultSet(sql);
	// DBを読み出してプルダウンメニューを作成する
	while(rs.next()) {
	    String genCode = rs.getString("GENERAL_CODE");
	    String genName = rs.getString("GENERAL_NAME");

	    optionStr += "<option value=" + "\"" + genCode + "\" ";

	    if(genCode.equals(queryStr)) {
		optionStr += "selected";
	    }

	    optionStr += ">" + genName + "</option>";
	}

    } catch (Exception e) {
    }
    
    optionStr += "</select>";  
    return optionStr;
}
%>

<%
    int DISP_NUM = 20;		//検索結果表示件数
    String daialogMsg = "";
    String sql;
    ResultSet rs;

    //文字コードを設定してクエリ情報を読み込む
    request.setCharacterEncoding("UTF-8");
    String queryProductCode = request.getParameter("inputProductCode");
    String queryProductName = request.getParameter("inputProductName");
    String queryBrand = request.getParameter("brand");
    String queryColor = request.getParameter("color");
    String queryClass = request.getParameter("classcode");
    String queryType = request.getParameter("type");
    String queryJanCode = request.getParameter("inputJanCode");
    String querySubmitBtn = request.getParameter("submitBtn");
    String queryPageIdTmp = request.getParameter("pageId");
    String queryOrderNoTmp = request.getParameter("orderNo");

    //クエリ情報がなかった時は""に置き換える
    if(queryProductCode == null) queryProductCode = "";
    if(queryProductName == null) queryProductName = "";
    if(queryBrand == null) queryBrand = "";
    if(queryColor == null) queryColor = "";
    if(queryClass == null) queryClass = "";
    if(queryType == null) queryType = "";
    if(queryJanCode == null) queryJanCode = "";

    if(querySubmitBtn == null ) {
	querySubmitBtn = "";
	offsetNum = 0;		//DB表示時のオフセット値を初期化する
    }

    if(queryPageIdTmp == null) queryPageIdTmp = "";
    if(queryOrderNoTmp == null) queryOrderNoTmp = "";

    //戻り先URLを作成する
    if(!queryPageIdTmp.equals("")) {
        queryPageId = "./" + queryPageIdTmp;
    }

    //戻すorderNoを作成する
    if(!queryOrderNoTmp.equals("")) {
        queryOrderNo = queryOrderNoTmp;
    }

    DatabeseAccess da = new DatabeseAccess();
    da.open();

    //-------------------ブランド選択肢を作成する----------------------------
    String optionStr = "<select name=\"brand\" class=\"minimal\">";//★
    optionStr += "<option value=\"\">選択</option>";
    String brandOption = doPullDownMake("BLD", queryBrand, optionStr);
    
    //-------------------カラー選択肢を作成する----------------------------
    optionStr = "<select name=\"color\" class=\"minimal\">";	    //★
    optionStr += "<option value=\"\">選択</option>";
    String colorOption = doPullDownMake("COR", queryColor, optionStr);
  
    //-------------------クラス選択肢を作成する----------------------------
    optionStr = "<select name=\"classcode\" class=\"minimal\">";	    //★
    optionStr += "<option value=\"\">選択</option>";
    String classOption = doPullDownMake("CLS", queryClass, optionStr);
    
    //-------------------分類選択肢を作成する----------------------------
    optionStr = "<select name=\"type\" class=\"minimal\">";	    //★
    optionStr += "<option value=\"\">選択</option>";
    String typeOption = doPullDownMake("TYP", queryType, optionStr);

    // セッションの取得
    String password = (String) session.getAttribute("Password");

    //SQL文を作成する
    sql = "PRODUCT_CODE, PRODUCT_NAME, BRAND, COLOR_CODE, CLASS, TYPE, SIZE, PRICE, STOCK, MATERIAL_FRONT, MATERIAL_INSIDE,JANCODE from products ";

    //商品コード、商品名： 部分一致
    sql += "where PRODUCT_CODE " + "like " + "\'%" + queryProductCode + "%\' ";

    //ブランド、カラー、クラス、分類   ： 選択された値のコード値
    sql += "and PRODUCT_NAME " + "like " + "\'%" + queryProductName + "%\' ";

    //複合条件の場合はAND検索をする
    if(!queryBrand.equals(""))	sql += "and BRAND=" + "\'" + queryBrand + "\' ";
    if(!queryColor.equals(""))	sql += "and COLOR_CODE=" + "\'" + queryColor + "\' ";
    if(!queryClass.equals(""))	sql += "and CLASS=" + "\'" + queryClass + "\' ";
    if(!queryType.equals(""))	sql += "and TYPE=" + "\'" + queryType + "\' ";
    if(!queryJanCode.equals("")) sql += "and JANCODE=" + "\'" + queryJanCode + "\' ";

    //検索データ件数を取得する
    String sqlCnt = "select count(*) ";
    sqlCnt += sql;
    ResultSet rsCnt = da.getResultSet(sqlCnt);
    
    String cnt = "0";

    while(rsCnt.next()) {
        cnt = rsCnt.getString("PRODUCT_CODE");
    }
    
    sql += "order by PRODUCT_CODE, PRODUCT_NAME limit " + DISP_NUM + " ";

    if(querySubmitBtn.equals("forward")){
	if(Integer.parseInt(cnt) > offsetNum + DISP_NUM){
            offsetNum += DISP_NUM;
	}
    }

    if(querySubmitBtn.equals("back")){
	if(offsetNum >= DISP_NUM) {
	    offsetNum -= DISP_NUM;
	}
    }

    sql += "offset " + String.valueOf(offsetNum) + ";";
    
    //SQL文を実行する
    rs = da.getResultSet("select " + sql);
    
    //テーブルヘッダー部を作成する
    String tableHTML = "<table class=\"table table-striped table-bordered text-nowrap\" id=\"searchTable\">";
    tableHTML += "<tr class=\"bg-dark\">";
    tableHTML += "<th scope=\"col\" class=\"text-white\">選択</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">商品コード</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">商品名</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">ブランド</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">カラー</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">クラス</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">分類</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">サイズ</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">商品単価</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">在庫数</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">素材(表)</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">素材（裏）</th>";
    tableHTML += "<th scope=\"col\" class=\"text-white\">JANコード</th>";
    tableHTML += "</tr>";
    tableHTML += "</thread>";

    tableHTML += "<tbody>";
    
    //検索件数を初期化する
    numOfSearch = 0;
    
    // テーブルの中身を作成する
    while(rs.next()) {
	numOfSearch++;	//検索件数をカウントする
        String productCode = rs.getString("PRODUCT_CODE");  // 商品コード
        String productName = rs.getString("PRODUCT_NAME");  // 商品名
        String brand = rs.getString("BRAND");		    // ブランド
        String color = rs.getString("COLOR_CODE");	    // カラー
        String classCd = rs.getString("CLASS");		    // クラス
        String type = rs.getString("TYPE");		    // 分類
        String size = rs.getString("SIZE");		    // サイズ
        String price = rs.getString("PRICE");		    // 商品単価
        String stock = rs.getString("STOCK");		    // 在庫数
        String materialFront = rs.getString("MATERIAL_FRONT");	// 素材(表)
        String materialInside = rs.getString("MATERIAL_INSIDE");// 素材（裏）
        String janCode = rs.getString("JANCODE");		// JANコード

        // テーブル用HTMLを作成する
        tableHTML += "<tr>";
	tableHTML += "<td scope=\"row\">"
		+ "<input type=\"radio\" name=\"options\" id=\"option" + numOfSearch + "\">" +"</td>"			
	    + "<td>" + productCode + "</td>"
	    + "<td>" + productName + "</td>"
	    + "<td>"+ brand + "</td>"
	    + "<td>"+ color + "</td>"
	    + "<td>"+ classCd + "</td>"
	    + "<td>"+ type + "</td>"
	    + "<td>"+ size + "</td>"
	    + "<td>"+ price + "</td>"
	    + "<td>"+ stock + "</td>"
	    + "<td>"+ materialFront + "</td>"
	    + "<td>"+ materialInside + "</td>"
	    + "<td>"+ janCode + "</td>"
	    + "</tr>";
    }

    tableHTML += "</tbody>";
    tableHTML += "</table>";

    // データベースへのコネクションを閉じる
    da.close();
    
    // ダイアログメッセージ作成
    if(queryProductCode.equals("") &&
	queryProductName.equals("") && 
	queryBrand.equals("") && 
	queryColor.equals("") && 
	queryClass.equals("") && 
	queryType.equals("") && 
	queryJanCode.equals("")) {
       
//kari
//	tableHTML = "";		//テーブルを非表示にする
//	daialogMsg = "window.alert(\"検索条件を入力してください。\")";
    } 

%>

<!DOCTYPE html>
<html lang="ja">
     
    <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
 
    <!-- Bootstrap CSS -->
    <%= bsCss %>

    <!-- view用CSS -->
    <link rel="stylesheet" href="../css/view.css">
    
    <title>商品検索</title>

    </head>
     
    <body>
	<%!
	    //静的変数
	    int offsetNum = 0;	    //DB表示時のオフセット値
	    int numOfSearch = 0;    //DB検索結果件数
	    String queryPageId = "";	//戻り先URL
	    String queryOrderNo = "";   //オーダーNo
	%>

	<input type="hidden" id="tmp_value1" value="<%= queryPageId %>">	
	<input type="hidden" id="tmp_value2" value="<%= queryOrderNo %>">	
	
	<h3 class="text-center mt-sm-4">商品検索</h3>
	<div class="container"><!-- container：箱 -->
	    <form action="productSearchPage.jsp" method="post">
		<INPUT TYPE='hidden' NAME='abc' VALUE='1234'>
		<INPUT TYPE='hidden' NAME='def' VALUE='5678'>

		<div class="row form-group" ><!-- row：1行目 -->
		    <div class="col-auto">
		        <label for="inputProductCode" class="col-form-label">商品コード</label>
			<input type="text" class="form-control" name="inputProductCode" placeholder="商品コードを入力" value=<%= queryProductCode %>>
		    </div>

		    <div class="col-auto">
			<label for="inputProductName" class="col-form-label">商品名</label>
			<input type="text" class="form-control" name="inputProductName" placeholder="商品名を入力" value=<%= queryProductName %>>
		    </div>
		    
		    <div class="col-3">
			<label for="inputJanCode" class="col-form-label">JANコード</label>
			<input type="text" class="form-control" name="inputJanCode" placeholder="JANコード" value=<%= queryJanCode %>>
		    </div>
		</div>


		<div class="row form-group input-group" ><!-- row：2行目 -->
		    <div class="col-auto">
			<label for="inputBrand" class="col-form-label">ブランド</label><br>
			<%= brandOption %>
		    </div>

		    <div class="col-auto">
			<label for="inputColor" class="col-form-label col-auto">カラー</label><br>
			<%= colorOption %>
		    </div>
		    
		    <div class="col-auto">
			<label for="inputClass" class="col-form-label col-auto">クラス</label><br>
			<%= classOption %>
		    </div>
		    
		    <div class="col-auto">
			<label for="inputType" class="col-form-label col-auto">分類</label><br>
			<%= typeOption %>
		    </div>
		</div>

		<div class="row form-group" ><!-- row：3行目 -->
		    <!-- 右寄せ -->
		    <div class="col-12 clearfix">
			<div class="float-right">全<%= cnt %>件中　<%= (offsetNum+1) %>～<%= offsetNum + numOfSearch %>件
			    <button class="btn btn-link" type="submit" name="submitBtn"  value="back">＜前</button>
			    <label for="inputType" class="col-form-label col-auto"><%= offsetNum / DISP_NUM + 1 %></label>
			    <button class="btn btn-link" type="submit" name="submitBtn" value="forward">次＞</button>
			    <button class="ml-sm-3 btn btn-secondary" type="submit">検索</button>
			</div>
		    </div>
		</div>
		
		<div class="text-center table-responsive-sm">
		    <%= tableHTML %>
		</div>

		<!-- 右寄せ -->
		<div class="col-11 clearfix float-right">
		    <div class="float-right">
			<!-- 直前のページに戻る -->
			<input class="btn btn-secondary" type="button" onclick="location.href='<%= queryPageId %>'" value="キャンセル">
			
			<!-- 選択ボタン -->
			<!-- <button class="ml-sm-3 btn btn-secondary" type="submit" name="submitBtn" value="selection">選択</button> -->
			<!-- <input class="ml-sm-3 btn btn-secondary" type="button" onclick="location.href='<%= queryPageId %>'" value="選択"> -->
			<input class="ml-sm-3 btn btn-secondary" type="button" id="selectButton" value="選択">
		    
		    </div>
		</div>
		    
		<!-- 検索条件なしの時のエラーダイアログ表示
		<script>
		    <%= daialogMsg %>
		</script>
	    </form>
  
	</div>
	
        <!-- Bootstrap JavaScript -->
	<%= bsJs %>

	<!-- JavaScript -->
	<script src='../js/productSearchEdit.js'></script> 
	
    </body>
</html>
