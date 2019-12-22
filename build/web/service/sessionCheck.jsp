<%-- 
    Document   : sessionCheck
    Created on : 2019/12/19, 1:12:13
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // セッションの取得
    String userId = (String) session.getAttribute("UserId");
    
    // セッションが取得できない場合はログインに遷移
    if(userId == null){
        response.sendRedirect("../view/loginpage.jsp?move=nosession");
    }
%>