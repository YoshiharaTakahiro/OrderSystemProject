<%-- 
	Document   : supplierSearchPage.jsp
	Created on : 2020/01/08
	Author     : masahiro.fujihara
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@include file="../service/bootstrap.jsp" %>
<%
	int DISP_NUM = 20;		//検索結果表示件数
	String daialogMsg = "";
	String sql;
	ResultSet rs;

	//文字コードを設定してクエリ情報を読み込む
	request.setCharacterEncoding("UTF-8");
	String querySupplierCode = request.getParameter("inputSupplierCode");
	String querySupplierName = request.getParameter("inputSupplierName");
	String queryTelephone = request.getParameter("inputTelephone");
	String queryPostalNumber = request.getParameter("inputPostalNumber");
	String queryAddress = request.getParameter("inputAddress");
	String querySubmitBtn = request.getParameter("submitBtn");
	String queryPageIdTmp = request.getParameter("pageId");
	String queryOrderCodeTmp = request.getParameter("orderCode");

	//クエリ情報がなかった時は""に置き換える
	if(querySupplierCode == null) querySupplierCode = "";
	if(querySupplierName == null) querySupplierName = "";
	if(queryTelephone == null) queryTelephone = "";
	if(queryPostalNumber == null) queryPostalNumber = "";
	if(queryAddress == null) queryAddress = "";
	if(querySubmitBtn == null ) {
		querySubmitBtn = "";
		offsetNum = 0;		//DB表示時のオフセット値を初期化する
	}

	if(queryPageIdTmp == null) queryPageIdTmp = "";
	if(queryOrderCodeTmp == null) queryOrderCodeTmp = "";

	//戻り先URLを作成する
	if(!queryPageIdTmp.equals("")) {
		queryPageId = "./" + queryPageIdTmp;
	}

	//戻すorderCodeを作成する
	if(!queryOrderCodeTmp.equals("")) {
		queryOrderCode = queryOrderCodeTmp;
	}

	DatabeseAccess da = new DatabeseAccess();
	da.open();

	// セッションの取得
	String password = (String) session.getAttribute("Password");

	//SQL文を作成する
	sql = "SUPPLIER_CODE, SUPPLIER_NAME, PHONE_NUMBER, POSTAL_NUMBER, ADDRESS from suppliers ";

	//取引先コード、取引先名、住所、電話番号、郵便番号： 部分一致
	sql += "where SUPPLIER_CODE " + "like " + "\'%" + querySupplierCode + "%\' ";
	sql += "and SUPPLIER_NAME " + "like " + "\'%" + querySupplierName + "%\' ";
	sql += "and PHONE_NUMBER " + "like " + "\'%" + queryTelephone + "%\' ";
	sql += "and POSTAL_NUMBER " + "like " + "\'%" + queryPostalNumber + "%\' ";
	sql += "and ADDRESS " + "like " + "\'%" + queryAddress + "%\' ";

	//検索データ件数を取得する
	String sqlCnt = "select count(*) ";
	sqlCnt += sql;
	ResultSet rsCnt = da.getResultSet(sqlCnt);

	String cnt = "0";

	while(rsCnt.next()) {
		cnt = rsCnt.getString("SUPPLIER_CODE");
	}
    
	sql += "order by SUPPLIER_CODE limit " + DISP_NUM + " ";

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
	tableHTML += "<th scope=\"col\" class=\"text-white\">取引先コード</th>";
	tableHTML += "<th scope=\"col\" class=\"text-white\">取引先名</th>";
	tableHTML += "<th scope=\"col\" class=\"text-white\">電話番号</th>";
	tableHTML += "<th scope=\"col\" class=\"text-white\">郵便番号</th>";
	tableHTML += "<th scope=\"col\" class=\"text-white\">住所</th>";
	tableHTML += "</tr>";
	tableHTML += "</thread>";

	tableHTML += "<tbody>";

	// 検索条件が無い時は検索結果を表示しない
	boolean seachDispEn = true;

	if(querySupplierCode.equals("") &&
		querySupplierName.equals("") && 
		queryTelephone.equals("") && 
		queryPostalNumber.equals("") && 
		queryAddress.equals("") ) {

		seachDispEn = false;
		offsetNum = 0;		    //検索条件が無い時は初期化する

		if(!querySubmitBtn.equals("")) {
			daialogMsg = "window.alert(\"検索条件を入力してください。\")";
		}
    } 

	//検索件数を初期化する
	numOfSearch = 0;

	// テーブルの中身を作成する
	while(rs.next() && seachDispEn) {
		numOfSearch++;	//検索件数をカウントする
		String productCode = rs.getString("SUPPLIER_CODE");	    // 取引先コード
		String productName = rs.getString("SUPPLIER_NAME");	    // 取引先名
		String productTelephone = rs.getString("PHONE_NUMBER");	    // 電話番号
		String productPostalNumber = rs.getString("POSTAL_NUMBER");  // 郵便番号
		String productAddress = rs.getString("ADDRESS");	    // 住所

		// テーブル用HTMLを作成する
		tableHTML += "<tr>";
		tableHTML += "<td scope=\"row\">"
			+ "<input type=\"radio\" name=\"options\" id=\"option" + numOfSearch + "\">" +"</td>"			
			+ "<td>" + productCode + "</td>"
			+ "<td>" + productName + "</td>"
			+ "<td>"+ productTelephone + "</td>"
			+ "<td>"+ productPostalNumber + "</td>"
			+ "<td>"+ productAddress + "</td>"
			+ "</tr>";
	}

	tableHTML += "</tbody>";
	tableHTML += "</table>";

	// データベースへのコネクションを閉じる
	da.close();
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

		<title>取引先検索</title>
	</head>
     
	<body>
		<%!
			//静的変数
			int offsetNum = 0;	    //DB表示時のオフセット値
			int numOfSearch = 0;    //DB検索結果件数
			String queryPageId = "";	//戻り先URL
			String queryOrderCode = "";   //オーダーNo
		%>

		<input type="hidden" id="tmp_value1" value="<%= queryPageId %>">	
		<input type="hidden" id="tmp_value2" value="<%= queryOrderCode %>">	

		<h3 class="text-center mt-sm-4">取引先検索</h3>
		
		<form action="supplierSearchPage.jsp" method="post">
			<div class="container"><!-- container：箱 -->
				<div class="row form-group" ><!-- row：1行目 -->
					<div class="col-auto">
						<label for="inputSupplierCode" class="col-form-label">取引先コード</label>
						<input type="text" class="form-control" name="inputSupplierCode" placeholder="取引先コードを入力" value=<%= querySupplierCode %>>
					</div>

					<div class="col-auto">
						<label for="inputSupplierName" class="col-form-label">取引先名</label>
						<input type="text" class="form-control" name="inputSupplierName" placeholder="取引先名を入力" value=<%= querySupplierName %>>
					</div>

					<div class="col-3">
						<label for="inputTelephone" class="col-form-label">電話番号</label>
						<input type="text" class="form-control" name="inputTelephone" placeholder="電話番号" value=<%= queryTelephone %>>
					</div>
				</div>

				<div class="row form-group" ><!-- row：2行目 -->
					<div class="col-auto">
						<label for="inputPostalNumber" class="col-form-label">郵便番号</label>
						<input type="text" class="form-control" name="inputPostalNumber" placeholder="郵便番号を入力" value=<%= queryPostalNumber %>>
					</div>

					<div class="col-auto">
						<label for="inputAddress" class="col-form-label">住所</label>
						<input type="text" class="form-control" name="inputAddress" placeholder="住所" value=<%= queryAddress %>>
					</div>
				</div>



				<div class="row form-group" ><!-- row：3行目 -->
					<!-- 右寄せ -->
					<div class="col-12 clearfix">
						<div class="float-right">全<%= cnt %>件中　<%= (offsetNum+1) %>～<%= offsetNum + numOfSearch %>件
							<button class="btn btn-link" type="submit" name="submitBtn"  value="back">＜前</button>
							<label for="inputType" class="col-form-label col-auto"><%= offsetNum / DISP_NUM + 1 %></label>
							<button class="btn btn-link" type="submit" name="submitBtn" value="forward">次＞</button>
							<button class="ml-sm-3 btn btn-secondary" type="submit" name="submitBtn" value="do">検索</button>
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
						<input class="ml-sm-3 btn btn-secondary" type="button" id="selectButton" value="選択">
					</div>
				</div>

				<script>
					<%= daialogMsg %>
				</script>
			</div>
		</form>

		<!-- Bootstrap JavaScript -->
		<%= bsJs %>

		<!-- JavaScript -->
		<script src='../js/supplierSearchEdit.js'></script> 
		
	</body>
</html>
