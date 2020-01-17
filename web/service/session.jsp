<%-- 
    Document   : session
    Created on : 2019/12/18, 23:29:16
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.math.BigInteger, java.security.MessageDigest" %>
<%
    // パラメータの取得
    String userId = request.getParameter("UserId");
    String password = request.getParameter("Password");
    
    // パスワードハッシュ化
    MessageDigest digest = MessageDigest.getInstance("SHA-256");
    digest.reset();
    digest.update(password.getBytes("utf8"));
    password = String.format("%064x", new BigInteger(1, digest.digest()));
    
    // ユーザチェック
    DatabeseAccess da = new DatabeseAccess();
    da.open();
    
    String sql = "select USER_NAME, POSITION from users "
               + "where USER_CODE = '" + userId + "' "
               + "and   PASSWORD = '" + password + "' "
               + "and   DELETE_FLAG = 0"; 
    ResultSet rs = da.getResultSet(sql);
    
    
    if(rs.next()){

        // セッションに登録
        session.setAttribute("UserId", userId);
        session.setAttribute("UserName", rs.getString("USER_NAME"));
        session.setAttribute("Position", rs.getString("POSITION"));
        
        // トップページにリダイレクト(遷移)
        response.sendRedirect("../view/toppage.jsp");

    }else{        
        // データが取得できない場合はログインに戻る
        response.sendRedirect("../view/loginpage.jsp?move=loginmiss");
    }

    da.close();
    
%>