/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
$(function () {
    
    // POSTでリダイレクトする
    var form = document.createElement('form');
    var request = document.createElement('input');     // 取引先コード

    form.method = 'POST';
    form.action = '../view/orderEditPage.jsp';
    
    request.type = 'hidden';
    request.name = 'orderCode';
    request.value = encodeURIComponent($('#orderCode').val());

    form.appendChild(request);
    document.body.appendChild(form);

    form.submit();

});