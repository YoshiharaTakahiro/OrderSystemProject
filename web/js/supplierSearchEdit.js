/* 
    Document   : supplierSearchEdit.js
    Created on : 2020/02/20
    Author     : masahiro.fujihara
 */

$(function () {

    // 選択ボタン処理
    $("#selectButton").click( function() {
                
        // 明細情報取得
        var table = document.getElementById('searchTable');
        var rows = table.rows.length;	    // 行数
	var supplierCode = '';		    // 取引先コード
	var supplierName = '';		    // 商品名
	var selFlg = false;		    // 選択フラグ

	// ラジオボタンが選択されている行のデータを抜き出す
	for(var i=1; i<rows; i++){
	    selFlg = table.rows[i].cells[0].children[0].checked;	// 選択フラグ

	    if(selFlg) {
		supplierCode = table.rows[i].cells[1].innerText;	// 取引先コード
		supplierName = table.rows[i].cells[2].innerText;	// 取引先名
		break;
	    }
	}
	
	//何も選択されていない場合の処理を追加
	if(selFlg) {

	    // 受注登録処理呼出
	    var form = document.createElement('form');

	    form.method = 'POST';
//	    form.action = './orderEditPage.jsp';	    //仮
	    form.action = document.getElementById("tmp_value1").value;
	    document.body.appendChild(form);

	    //返却するデータを作成する
	    var request1 = document.createElement('input');
	    request1.type = 'hidden'; //入力フォームが表示されないように
	    request1.name = 'supplierCode';
	    request1.value = supplierCode;
	    form.appendChild(request1);

	    //返却するデータを作成する
	    var request2 = document.createElement('input');
	    request2.type = 'hidden'; //入力フォームが表示されないように
	    request2.name = 'supplierName';
	    request2.value = supplierName;
	    form.appendChild(request2);

	    //返却するデータを作成する
	    var request6 = document.createElement('input');
	    request6.name = 'orderCode';
	    request6.value = document.getElementById("tmp_value2").value;
	    form.appendChild(request6);
	    
	    form.submit();
	    
	} else {
	    alert('取引先を選択してください。');
	}

        
    });
});


