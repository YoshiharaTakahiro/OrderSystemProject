<%-- 
    Document   : tabHeder
    Created on : 2020/01/14, 19:58:48
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // ユーザ名取得
    String userid = (String) session.getAttribute("UserId");
    String username = (String) session.getAttribute("UserName");


    String tabHederHTML = ""
            + "<h5 class=\"text-right mt-3 mr-3\">" + userid + " : " + username + " <input class=\"btn btn-secondary\" type=\"button\" onclick=\"location.href='../service/logout.jsp'\" value=\"ログアウト\"></h5> "
            + "<!-- タブ部分 --> "
            + "<ul class=\"nav nav-tabs mx-5\"> "
            + "<li class=\"nav-item\"><a class=\"nav-link active\" href=\"./toppage.jsp\">受注</a></li> "
            + "<li class=\"nav-item\"><a class=\"nav-link disabled\" href=\"#\">取引先</a></li> "
            + "<li class=\"nav-item\"><a class=\"nav-link disabled\" href=\"#\">商品</a></li> "
            + "<li class=\"nav-item\"><a class=\"nav-link disabled\" href=\"#\">カテゴリ</a></li> "
            + "<li class=\"nav-item\"><a class=\"nav-link disabled\" href=\"#\">売上日計</a></li> "
            + "<li class=\"nav-item\"><a class=\"nav-link disabled\" href=\"#\">営業別</a></li> "
            + "<li class=\"nav-item\"><a class=\"nav-link disabled\" href=\"#\">取引別</a></li> "
            + "<li class=\"nav-item\"><a class=\"nav-link disabled\" href=\"#\">商品別</a></li> "
            + "</ul>";
%>
