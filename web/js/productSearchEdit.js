/* 
    Document   : productSearchEdit.js
    Created on : 2020/01/22
    Author     : masahiro.fujihara
 */

$(function () {

    // 選択ボタン処理
    $("#selectButton").click( function() {
                
        // 明細情報取得
        var table = document.getElementById('searchTable');
        var rows = table.rows.length; // 行数
        
        // パラメータ作成
        var parameterJson = [];
        
//        var test = document.getElementById('inputProductCode');
        var test = document.getElementsByName('inputProductCode');
        test.value = "";

        // ラジオボタンが選択されている行のデータを抜き出す
        for(var i=1; i<rows; i++){
            var selFlg = table.rows[i].cells[0].children[0].checked;		// 選択フラグ

	    if( selFlg == true) {
		var productCode = table.rows[i].cells[1].innerText;		// 商品コード
//                var colorCode = table.rows[i].cells[3].children[0].value;     // カラーコード
		var colorCode = table.rows[i].cells[4].innerText;		// カラーコード
//		var price = Number(table.rows[i].cells[8].innerText.replace(/,/g, '').substring(1));;   // 価格
		var price = Number(table.rows[i].cells[8].innerText);		// 価格
		var productCount = table.rows[i].cells[9].innerText;		// 個数

		var productJson = {
//		    selFlg : selFlg,
		    productCode : productCode,
		    colorCode : colorCode,
		    price : price,
		    productCount : productCount
		};
		
                parameterJson[i-1] = productJson;
		break;
	    }
        }
         
        // 受注登録処理呼出
        var form = document.createElement('form');
        var request = document.createElement('input');

        form.method = 'POST';
//        form.action = queryPageId;
        form.action = './orderEditPage.jsp';	    //仮　本当は変数で

        request.type = 'hidden'; //入力フォームが表示されないように

//        "productCode"
//        "productName"
//        "colorCode"
//        "stock"
//        "price"

	
	request.name = 'parameterJson';
        request.value = JSON.stringify(parameterJson);

        form.appendChild(request);
        document.body.appendChild(form);

        form.submit();
        
        test.value = JSON.stringify(parameterJson);
        
    });
    
    
});


