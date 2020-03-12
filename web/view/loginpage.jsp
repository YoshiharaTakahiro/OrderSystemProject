<%-- 
    Document   : loginpage
    Created on : 2019/12/18, 23:01:40
    Author     : Yoshihara Takahiro
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../service/bootstrap.jsp" %>
<%
    // 強制移動された場合は、アラートメッセージ表示する。
    String move = (String) request.getParameter("move");
    String errMsg = "";
    if(move != null){
        errMsg = "<div class='alert alert-warning alert-dismissible fade show' role='alert'> ";                 
        if(move.equals("logout")){
            errMsg += "ログアウトしました。";
        }else if(move.equals("nosession")){
            errMsg += "セッションが切れています。再ログインしてください。";            
        }else if(move.equals("loginmiss")){
            errMsg = errMsg.replace("alert-warning", "alert-danger");
            errMsg += "ユーザIDまたはパスワードが間違っています。";
        }
        errMsg += "<button type='button' class='close' data-dismiss='alert' aria-label='Close'>" ;
        errMsg += "<span aria-hidden='true'>&times;</span>" ;
        errMsg += "</button>";
        errMsg += "</div>";        
    }
    
    // ゴミとして残っているクッキー情報がある場合は削除する。
    Cookie cookie = new Cookie("newProRow", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);
    
    cookie = new Cookie("newSupplier", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);
    
    cookie = new Cookie("newSupplierName", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);
    
    cookie = new Cookie("newDeliveryDate", "");
    cookie.setMaxAge(0);
    response.addCookie(cookie);

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%= bsCss %>
        <title>受発注システム</title>
    </head>
    <body>
        <div class="container">
            <h1 class="text-center m-5">受発注管理システム<br>ログイン</h1>
            <%= errMsg %>
            <form method="post" action="../service/session.jsp">
                <div class="form-group">
                    <h5>ユーザID</h5>
                    <input type="text" class="form-control" name="UserId"   placeholder="ユーザIDを入力してください"/>
                </div>
                <div class="form-group">
                    <h5>パスワード</h5>
                    <input type="password" class="form-control" name="Password"  placeholder="パスワードを入力してください"/>
                </div>
                <input class="btn btn-secondary btn-block mt-4" type="submit" value="ログイン">
            </form>
        </div>

        <%= bsJs %>

    </body>
</html>
