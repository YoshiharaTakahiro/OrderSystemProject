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
        var rows = table.rows.length;	    // 行数
	var productCode = '';		    // 商品コード
	var productName = '';		    // 商品名
	var colorCode = '';		    // カラーコード
	var price = '';			    // 価格
	var stock = '';			    // 個数

	// ラジオボタンが選択されている行のデータを抜き出す
	for(var i=1; i<rows; i++){
	    var selFlg = table.rows[i].cells[0].children[0].checked;		// 選択フラグ

	    if(selFlg) {
		productCode = table.rows[i].cells[1].innerText;		// 商品コード
		productName = table.rows[i].cells[1].innerText;		// 商品名
		colorCode = table.rows[i].cells[4].innerText;		// カラーコード
		price = Number(table.rows[i].cells[8].innerText);		// 価格
		stock = table.rows[i].cells[9].innerText;		// 個数

		break;
	    }
	}

        // 受注登録処理呼出
	var form = document.createElement('form');
	var request = document.createElement('input');

	form.method = 'POST';
	form.action = './orderEditPage.jsp';	    //仮　本当は変数で
	request.type = 'hidden'; //入力フォームが表示されないように

	//返却するデータを作成する
	request.name = 'productCode';
	request.value = productCode;
	form.appendChild(request);
	document.body.appendChild(form);

	//返却するデータを作成する
	request.name = 'productName';
	request.value = productName;
	form.appendChild(request);
	document.body.appendChild(form);

	//返却するデータを作成する
	request.name = 'colorCode';
	request.value = colorCode;
	form.appendChild(request);
	document.body.appendChild(form);

	//返却するデータを作成する
	request.name = 'stock';
	request.value = stock;
	form.appendChild(request);
	document.body.appendChild(form);

	//返却するデータを作成する
	request.name = 'price';
	request.value = price;
	form.appendChild(request);
	document.body.appendChild(form);

	form.submit();
        
    });
});


