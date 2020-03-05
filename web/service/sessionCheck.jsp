<%-- 
    Document   : sessionCheck
    Created on : 2019/12/19, 1:12:13
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // セッションの取得
    String userId = (String) session.getAttribute("UserId");
    
    // システム管理者情報
    Boolean sysFlg = false;
    if(session.getAttribute("Position").toString().equals("9") && session.getAttribute("DepartmentCode").toString().equals("SYS")){
        sysFlg = true;
    }
    
    // セッションが取得できない場合はログインに遷移
    if(userId == null){
        response.sendRedirect("../view/loginpage.jsp?move=nosession");
    }
%>