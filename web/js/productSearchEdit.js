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
		price = Number(table.rows[i].cells[8].innerText);	// 価格
		stock = table.rows[i].cells[9].innerText;		// 個数

		break;
	    }
	}

        // 受注登録処理呼出
	var form = document.createElement('form');

	form.method = 'POST';
//	form.action = '<%= queryPageId %>';
	form.action = './orderEditPage.jsp';	    //仮　本当は変数で
	document.body.appendChild(form);

	//返却するデータを作成する
	var request1 = document.createElement('input');
	request1.type = 'hidden'; //入力フォームが表示されないように
	request1.name = 'productCode';
	request1.value = productCode;
	form.appendChild(request1);

	//返却するデータを作成する
	var request2 = document.createElement('input');
	request2.type = 'hidden'; //入力フォームが表示されないように
	request2.name = 'productName';
	request2.value = productName;
	form.appendChild(request2);

	//返却するデータを作成する
	var request3 = document.createElement('input');
	request3.type = 'hidden'; //入力フォームが表示されないように
	request3.name = 'colorCode';
	request3.value = colorCode;
	form.appendChild(request3);

	//返却するデータを作成する
	var request4 = document.createElement('input');
	request4.type = 'hidden'; //入力フォームが表示されないように
	request4.name = 'stock';
	request4.value = stock;
	form.appendChild(request4);

	//返却するデータを作成する
	var request5 = document.createElement('input');
	request5.name = 'price';
	request5.value = price;
	form.appendChild(request5);

	form.submit();
        
    });
});


