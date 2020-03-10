<%-- 
    Document   : oderListPage
    Created on : 2020/03/04, 13:05:03
    Author     : mcato
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@include file="../service/sessionCheck.jsp" %>
<%@include file="../service/tabHeder.jsp" %>

<%@include file="../service/bootstrap.jsp" %>

<%
    
    // ユーザ名取得
    //String username = (String) session.getAttribute("UserName");
    //役職取得
    String pos = (String) session.getAttribute("Position");
    //ID取得
    String usrId =  (String) session.getAttribute("UserId");
    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
//    String cnt = "";
    String tableHTML = "";
    
    
   // String sql = "select count(*) As cnt from city";
   String sql = "SELECT count(*) As cnt FROM ORDERS";
    //if(password != null){
    //    sql += " where District = '" + password + "'";
    //}
    
    ResultSet rs = da.getResultSet(sql);
    
    String cnt = "0";
    while(rs.next()) {
        cnt = rs.getString("cnt");
    }
    

     //もともとのコード　条件なし→全件
    //sql = "select ORDER_CODE,ORDER_DATE, SUPPLIER_CODE,DELIVERY_DATE, DEPARTMENT_CODE,USER_CODE from ORDERS ";
 
    //役職→管理者なら自分のIDの所属部署全件、一般なら自分のIDと同じ範囲で取得
    if(pos.equals("1")){
        //管理者　自分の部署全件
            sql = "select DEPARTMENT_CODE from USERS where USER_CODE = '" + usrId + "' ";
            //sql = "select DEPARTMENT_CODE from USERS where USER_CODE = '10000001'";
            rs = da.getResultSet(sql);
            while (rs.next()) {
                String dpt = rs.getString("DEPARTMENT_CODE");
                if(dpt != null){
                    //sql = "select ORDER_CODE,ORDER_DATE, SUPPLIER_CODE,DELIVERY_DATE, DEPARTMENT_CODE,USER_CODE from ORDERS ";
                    //sql += "where DEPARTMENT_CODE = '" + dpt +"' ";
                    sql  = "select o.ORDER_CODE, DATE_FORMAT(o.ORDER_DATE, '%Y/%m/%d') ORDER_DATE, DATE_FORMAT(o.DELIVERY_DATE, '%Y/%m/%d') DELIVERY_DATE, o.SUPPLIER_CODE, s.SUPPLIER_NAME, o.DEPARTMENT_CODE, d.DEPARTMENT_NAME, o.USER_CODE, u.USER_NAME ";
                    sql += "from ORDERS o, SUPPLIERS s, USERS u, DEPARTMENTS d ";
                    sql += "where o.SUPPLIER_CODE = s.SUPPLIER_CODE ";
                    sql += "and o.DEPARTMENT_CODE = d.DEPARTMENT_CODE ";
                    sql += "and o.USER_CODE = u.USER_CODE ";                   
                    sql += "and o.DEPARTMENT_CODE = '" + dpt +"' ";
                    sql += "and o.DELETE_FLAG = false ";
                }
            }
    }else if(sysFlg == true){
            //管理者、デリートフラグも関係なし全件
            //sql = "select ORDER_CODE,ORDER_DATE, SUPPLIER_CODE,DELIVERY_DATE, DEPARTMENT_CODE,USER_CODE from ORDERS ";
               sql  = "select o.ORDER_CODE, DATE_FORMAT(o.ORDER_DATE, '%Y/%m/%d') ORDER_DATE, DATE_FORMAT(o.DELIVERY_DATE, '%Y/%m/%d') DELIVERY_DATE, o.SUPPLIER_CODE, s.SUPPLIER_NAME, o.DEPARTMENT_CODE, d.DEPARTMENT_NAME, o.USER_CODE, u.USER_NAME ";
               sql += "from ORDERS o, SUPPLIERS s, USERS u, DEPARTMENTS d ";
               sql += "where o.SUPPLIER_CODE = s.SUPPLIER_CODE ";
               sql += "and o.DEPARTMENT_CODE = d.DEPARTMENT_CODE ";
               sql += "and o.USER_CODE = u.USER_CODE ";
    }else{
        //一般→自分の受注案件のみ
        //sql = "select ORDER_CODE,ORDER_DATE, SUPPLIER_CODE,DELIVERY_DATE, DEPARTMENT_CODE,USER_CODE from ORDERS ";
        //sql += " where USER_CODE = '" + usrId + "' ";

                    sql  = "select o.ORDER_CODE, DATE_FORMAT(o.ORDER_DATE, '%Y/%m/%d') ORDER_DATE, DATE_FORMAT(o.DELIVERY_DATE, '%Y/%m/%d') DELIVERY_DATE, o.SUPPLIER_CODE, s.SUPPLIER_NAME, o.DEPARTMENT_CODE, d.DEPARTMENT_NAME, o.USER_CODE, u.USER_NAME ";
                    sql += "from ORDERS o, SUPPLIERS s, USERS u, DEPARTMENTS d ";
                    sql += "where o.SUPPLIER_CODE = s.SUPPLIER_CODE ";
                    sql += "and o.DEPARTMENT_CODE = d.DEPARTMENT_CODE ";
                    sql += "and o.USER_CODE = u.USER_CODE ";                   
                    sql += " and o.USER_CODE = '" + usrId + "' ";
                    sql += "and o.DELETE_FLAG = false ";
    }


    /*//何のため？
    if(password != null){
        //sql += " where District = '" + password + "'";
        sql += " and District = '" + password + "' ";
    }
    */
    sql += " order by ORDER_CODE limit 100";
    rs = da.getResultSet(sql);
        // 取引先検索画面から戻ってきたとき
    String supplierCode ="";
    String supplierSearchCode = (String) request.getParameter("supplierCode");
    if(supplierSearchCode != null){
       // 取引先コードと取引先名を設定する。
       supplierCode = supplierSearchCode;
    }
    // 一覧表示用のテーブル
    //String 
    tableHTML = "<table class='table table-striped table-bordered' id='orderTable'>";
    tableHTML += "<thead class='thead-dark'><tr class='bg-dark'><th scope='col' class='text-white'>受注コード</th><th scope='col' class='text-white'>受注日</th><th scope='col' class='text-white'>取引先コード</th><th scope='col' class='text-white'>取引先名</th><th scope='col' class='text-white'>納品日</th><th scope='col' class='text-white'>部署</th><th scope='col' class='text-white'>受注者</th></tr></thead>";
    tableHTML += "<tbody id='itemRecord'>";
    // 取得された各結果に対しての処理
    while(rs.next()) {
        String odrCode = rs.getString("ORDER_CODE");
        String odrDate = rs.getString("ORDER_DATE");
        String supCode = rs.getString("SUPPLIER_CODE");//実際には取引先名も必要
        String supName = rs.getString("SUPPLIER_NAME");
        String dlvDate = rs.getString("DELIVERY_DATE");
        
        String dptCode = rs.getString("DEPARTMENT_CODE"); // 実際は部署名
        String dptName = rs.getString("DEPARTMENT_NAME"); 
        String usrCode = rs.getString("USER_CODE"); // 実際は受注者名
        String usrName = rs.getString("USER_NAME");
        //この中でUSER_CODEからUSER_NAMEをUSERSから取得したいがrsを同時使用できないらしいので、予め結合するしかないか？

        String[] arrayOdrDate = odrDate.split("/",0);
       

        // テーブル用HTMLを作成
        tableHTML += "<tr><td scope='row' class='orderE' id='"+ odrCode +"'>" + odrCode + "</td>";
        tableHTML += "<td class='" + arrayOdrDate[0] +"-" + arrayOdrDate[1] + "'>" + odrDate + "</td>";
        tableHTML += "<td class='"+ supCode +"'>" + supCode + "</td>";
        tableHTML += "<td >" + supName + "</td>";
        tableHTML += "<td>" + dlvDate + "</td>";
        tableHTML += "<td class='"+ dptCode +"'>" + dptName + "</td>";
        tableHTML += "<td class='"+ usrCode +"'>" + usrName +"</td></tr>";
    }

    tableHTML += "</body></table>";
    //ここまで

   //tableHTML += "<p>"+ cnt +"</p>";
    // データベースへのコネクションを閉じる
    da.close();

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>受発注システム</title>
        <!-- Bootstrap CSS -->
        <%= bsCss %>
        <style>
        
        </style>
    </head>
    <body>
       <!-- タブヘッダー部 -->
        <%= tabHederHTML %>
        
                
 

	<h2 class="text-center mt-3">受注一覧</h2>
        <div class="container-fluid">
           <!--
        <p><%= usrId %>：<%= username %>　　<input type="button" onclick="location.href='../service/logout.jsp'" value="ログアウト"><br></p>
     <p>sessionID=<%= session.getId() %></p>
        
        
        <input type="button" onclick="location.href='./orderEditPage.jsp'" value="受注画面（新規）"><br>
        -->
      
        <form class="mx-5">
            
            <!-- 受注ヘッダー部 -->
        <div class="row form-group" >
            <div class="col-md-3">
                        <label for="orderCode" class="col-form-label">受注番号</label>
                        <input type="number" class="form-control" id="orderCodeBox" value="">
            </div>            

            <div class="col-md-3">
                        <label for="orderDate" class="col-form-label">年月</label>
                        <input type="month" class="form-control" id="orderDateBox" value="">
            </div>            

            <div class="col-md-3">
                        <label for="supplierCode" class="col-form-label">取引先コード</label>
                        <input type="text" class="form-control" id="supplierCodeBox" value=<%= supplierCode %>>
            </div> 

            <div class="col-md-1">
                <label> 　</label>
                <input type="button" class="btn btn-secondary" id="searchSupplierButton" value="検索">
            </div>            
            
            <div class="col-md-1">
                        <label> 　</label>
                        <input type="button" class="btn btn-secondary" id="insertButton" value="登録">
            </div>            
        </div>
        </form>
        <p>
   
            <b>データの一覧(最大表示100件)</b><br>
            <%= tableHTML %>
        </p>
        <form name="f1" action="orderEditPage.jsp" method="post" >
            <input type="hidden" name="orderCode" value="" >
        </form>
    
    </div>
 
            <!-- Bootstrap JavaScript -->
        <%= bsJs %>  

       <script src='../js/orderList.js'></script>  
    </body>
</html>
