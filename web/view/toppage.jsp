<%-- 
    Document   : toppage
    Created on : 2019/12/18, 23:15:35
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@include file="../service/sessionCheck.jsp" %>
<%
    
    // ユーザ名取得
    String username = (String) session.getAttribute("UserName");
    
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    String cnt = "";
    String tableHTML = "";
    
    /*
    String sql = "select count(*) As cnt from city";
    if(password != null){
        sql += " where District = '" + password + "'";
    }
    
    ResultSet rs = da.getResultSet(sql);
    
    String cnt = "0";
    while(rs.next()) {
        cnt = rs.getString("cnt");
    }
    
    sql = "select District, Name from city ";
    if(password != null){
        sql += " where District = '" + password + "'";
    }
    sql += "order by District, Name limit 100";
    rs = da.getResultSet(sql);
    
    // メンバー一覧表示用のテーブル
    String tableHTML = "<table border=1>";
    tableHTML += "<tr bgcolor=\"000080\"><td><font color=\"white\">市名</font></td>"
        + "<td><font color=\"white\">町名</font></td>";

    // 取得された各結果に対しての処理
    while(rs.next()) {

        String name = rs.getString("District"); // メンバー名を取得
        String kana = rs.getString("Name"); // メンバー名(カナ)を取得

        // テーブル用HTMLを作成
        tableHTML += "<tr><td>" + name + "</td><td>" + kana + "</td></tr>";
    }

    tableHTML += "</table>";
*/

    // データベースへのコネクションを閉じる
    da.close();

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>受発注システム</title>
    </head>
    <body>
        <h1>トップページ</h1>
        <p>ようこそ<%= username %>さん</p>
        <p>sessionID=<%= session.getId() %></p>
        <input type="button" onclick="location.href='../service/logout.jsp'" value="ログアウト">
        
        <p>
            データ件数は<%= cnt %>です。<br>
            <b>データの一覧(最大表示100件)</b><br>
            <%= tableHTML %>
        </p>
        
    </body>
</html>
