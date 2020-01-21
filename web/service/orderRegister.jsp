<%-- 
    Document   : orderRegister
    Created on : 2020/01/20, 14:11:18
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, mydb.DatabeseAccess" %>
<%@page import="java.io.*, java.util.*"%>
<%
    // 受注明細情報取得
    String order = request.getParameter("parameterJson");

   


    // 受注明細番号表示
    response.sendRedirect("../view/orderEditPage.jsp?test="+order);
%>