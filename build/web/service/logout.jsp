<%-- 
    Document   : logout
    Created on : 2019/12/19, 0:22:19
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // セッションの終了(セッション変数の解放)
    session.invalidate();
        
    // ログインページにリダイレクト(遷移)
    response.sendRedirect("../view/loginpage.jsp?move=logout");
%>