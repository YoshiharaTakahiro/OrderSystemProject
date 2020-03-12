/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
$(function () {
    
    // POSTでリダイレクトする
    var form = document.createElement('form');
    var request = document.createElement('input');            // 取引先コード
    var successMesRequest = document.createElement('input');   // 正常終了メッセージ
    var stockMesRequest = document.createElement('input');   // 在庫エラーメッセージ

    form.method = 'POST';
    form.action = '../view/orderEditPage.jsp';
    
    request.type = 'hidden';
    request.name = 'orderCode';
    request.value = encodeURIComponent($('#orderCode').val());
    form.appendChild(request);

    successMesRequest.type = 'hidden';
    successMesRequest.name = 'successMessage';
    successMesRequest.value = encodeURIComponent($('#successMessage').val());
    form.appendChild(successMesRequest);

    stockMesRequest.type = 'hidden';
    stockMesRequest.name = 'stockMessage';
    stockMesRequest.value = encodeURIComponent($('#stockMessage').val());
    form.appendChild(stockMesRequest);

    document.body.appendChild(form);

    form.submit();

});