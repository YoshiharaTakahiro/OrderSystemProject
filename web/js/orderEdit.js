/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
$(function () {
    
    // フォーマット
    var numFor = new Intl.NumberFormat('ja-JP', { style: 'currency', currency: 'JPY' });

    // 個数変更処理
    var updateSubtotal = function(obj, productCount){
        
        // 在庫・単価の取得
        var stock = obj.parentNode.parentNode.children[4].innerText;
        var price = obj.parentNode.parentNode.children[5].innerText;
        price = Number(price.replace(/,/g, '').substring(1));
        
        // 小計更新
        obj.parentNode.parentNode.children[7].innerText = numFor.format(price * productCount);
        
        // 税・合計更新
        var table = document.getElementById('orderDetailTable');
        var rows = table.rows.length;

        // 合計額計算
        var newSum = 0;
        for(var i=1; i<rows-3; i++){
            
            var deleteFlg = table.rows[i].cells[0].children[0].checked;
            var wksum = table.rows[i].cells[7].innerText;
            wksum = Number(wksum.replace(/,/g, '').substring(1));
            
            // 削除フラグがOFFのみ計算
            if(!deleteFlg){
                newSum += wksum;
            }
        }
        
        var tax = document.getElementById('tax');
        var total = document.getElementById('total');
        var taxHidden = document.getElementById('taxHidden');
        
        tax.innerText = numFor.format(newSum * taxHidden.value);
        total.innerText = numFor.format(newSum + newSum * taxHidden.value);
        
    }
    
    // 削除フラグ変更処理
    $(".deleteCheck").change(function(){
        // 数量オブジェクト取得
        var productCountObj = this.parentNode.parentNode.children[6].children[0];
        var productCount = productCountObj.value;

        updateSubtotal(productCountObj, productCount);
    });
        
    // カラープルダウン変更処理
    var changeStock = function(){

        // 商品コード、カラーコード取得
        var productCode = this.parentNode.parentNode.children[1].innerText;
        var colorCode = this.value;
        
        // 在庫、単価、個数オブジェクト設定
        var stockObj = this.parentNode.parentNode.children[4];
        var priceObj = this.parentNode.parentNode.children[5];
        var productCountObj = this.parentNode.parentNode.children[6].children[0];
        
        // 選択が選ばれた場合
        if(colorCode == ""){
            stockObj.innerText = 0; 
            priceObj.innerText = numFor.format(0);
            productCountObj.value = "";
            updateSubtotal(productCountObj, 0);     
            return;
        }
        

        // 在庫・単価の取得(prodcutStockCheck)
        // 非同期通信で商品情報を取得する。
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "../service/productStockCheck.jsp");
        xhr.setRequestHeader("content-type", "application/x-www-form-urlencoded;charset=UTF-8");
        xhr.send("productCode="+productCode+"&colorCode="+colorCode);
        
        xhr.onreadystatechange = function(){
            
            // 通信完了(4)かつ正常終了(200)の場合
            if(xhr.readyState === 4 && xhr.status === 200) {
                
                var resText = xhr.responseText;                
                var info = JSON.parse(resText);

                // 在庫・単価・小計の更新
                stockObj.innerText = info.stock - info.allocation; 
                priceObj.innerText = numFor.format(info.price);
                productCountObj.value = "";
                updateSubtotal(productCountObj, 0);                
            }
        }
    };
    $(".colorPull").change(changeStock);
    
    // 個数変更イベント
    var changeProductCount = function(){        
        // 変更した個数を取得
        var newProductCount = this.value;
        updateSubtotal(this, newProductCount);        
    }
    $(".productCount").change(changeProductCount);
    
    
    // 取引先コード変更
    $("#supplierCode").change( function(){
        var supplierCode = this.value;
        
        // 非同期通信で取引先情報を取得する。
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "../service/supplierCheck.jsp");
        xhr.setRequestHeader("content-type", "application/x-www-form-urlencoded;charset=UTF-8");
        xhr.send("supplierCode="+supplierCode);
        
        xhr.onreadystatechange = function(){
            
            // 通信完了(4)かつ正常終了(200)の場合
            if(xhr.readyState === 4 && xhr.status === 200) {
                
                var resText = xhr.responseText;
                var supplierInfo = JSON.parse(resText);
                
                var supplierSt = document.getElementById('supplierName');
                supplierSt.value = supplierInfo.supplierName
                    
            }
        }
        
    });

    
    // 商品追加ボタン
    $("#addProductBt").click( function() {
        
        // 商品コード取得
        var addProductCode = $("#addProductCode").val();
        if(addProductCode == ""){
            return;
        }

        // 非同期通信で商品情報を取得する。
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "../service/productCheck.jsp");
        xhr.setRequestHeader("content-type", "application/x-www-form-urlencoded;charset=UTF-8");
        xhr.send("productCode="+addProductCode);
        
        xhr.onreadystatechange = function(){
            
            // 通信完了(4)かつ正常終了(200)の場合
            if(xhr.readyState === 4 && xhr.status === 200) {
                
                // 商品存在チェックおよび
                // 商品名、カラー、在庫、単価はデータベースから取得
                var resText = xhr.responseText;                
                var productInfo = JSON.parse(resText);
                                
                // 明細情報取得
                var table = document.getElementById('orderDetailTable');
                var rows = table.rows.length; // 行数

                // 新規行追加
                var row = table.insertRow(rows-3);

                // 新規列追加
                var productDelCol   = row.insertCell(-1);
                var productCodeCol  = row.insertCell(-1);
                var productNameCol  = row.insertCell(-1);
                var colorCol        = row.insertCell(-1);
                var stockCol        = row.insertCell(-1);
                var orderPriceCol   = row.insertCell(-1);
                var productCountCol = row.insertCell(-1);
                var subtotalCol     = row.insertCell(-1);

                // オブジェクト生成
                var checkBoxObj = "<td><input type=\"checkbox\"  class=\"form-control form-control-sm\" id=\"proDel\"></td>";
                var textBoxObj = "<input type=\"text\" class=\"form-control form-control-sm productCount\" value=\"0\">";
                
                var pulldownObj = "<select name=\"color\" class=\"form-control-sm colorPull\"> <option value=\"\" selected>選択</option> "
                for( var i=0; i<productInfo.colors.length; i++){                    
                    pulldownObj += "<option value=\"" + productInfo.colors[i].colorCode + "\" >" +  productInfo.colors[i].color + "</option> ";
                }
                pulldownObj += "</select>"
                
                // 仮明細番号
                var wkDetailCode = "<input type=\"hidden\" value=\"0\">"
                
                // 列の内容
                productDelCol.innerHTML   = checkBoxObj;
                productCodeCol.innerHTML  = addProductCode + wkDetailCode;
                productNameCol.innerHTML  = productInfo.productName;
                colorCol.innerHTML        = pulldownObj;
                stockCol.innerHTML        = 0;
                orderPriceCol.classList.add("text-right");
                orderPriceCol.innerHTML   = numFor.format(0);
                productCountCol.innerHTML = textBoxObj;
                subtotalCol.classList.add("text-right");
                subtotalCol.innerHTML     = numFor.format(0);
                
                // プルダウン変更イベント再設定
                $(".colorPull").off ('change', changeStock);
                $(".colorPull").on('change', changeStock);
                
                // 個数変更イベント再設定
                $(".productCount").off ('change', changeProductCount);
                $(".productCount").on('change', changeProductCount);
                
            }
        }

        // 商品コードクリア
        $("#addProductCode").val("");
        
    });
    
    // 商品情報をJSONにする
    var productJsonCreate = function(){

        // 明細情報取得
        var table = document.getElementById('orderDetailTable');
        var rows = table.rows.length; // 行数

        // パラメータ作成
        var parameterJson = [];
        
        // JSON配列用インデックス
        var inx = 0;
        // rows-3:新規行、税率行、合計行を除いた行
        for(var i=1; i<rows-3; i++){
            
            var deleteFlg = table.rows[i].cells[0].children[0].checked;          // 削除フラグ            
            var productCode = table.rows[i].cells[1].innerText;                  // 商品コード
            var detailCode = Number(table.rows[i].cells[1].children[0].value);   // 明細番号
            var productName = table.rows[i].cells[2].innerText;                  // 商品名
            var colorCode = table.rows[i].cells[3].children[0].value;            // カラーコード
            var stock = Number(table.rows[i].cells[4].innerText);                // 在庫数
            var price = Number(table.rows[i].cells[5].innerText.replace(/,/g, '').substring(1));    // 価格
            var productCount = Number(table.rows[i].cells[6].children[0].value); // 個数
            var subtotal = Number(table.rows[i].cells[7].innerText.replace(/,/g, '').substring(1)); // 小計
                        
            var productJson = {
                deleteFlg : deleteFlg,
                detailCode : detailCode,
                productCode : productCode,
                productName : productName,
                colorCode : colorCode,
                stock : stock,
                price : price,
                productCount : productCount,
                subtotal : subtotal
            };
            
            parameterJson[inx] = productJson;
            inx++;

        }
        
        return parameterJson;
        
    }

    // 登録・更新処理呼出メソッド
    var orderRegister = function(process){
        // 入力チェック
        if($('#supplierCode').val() == '' ){
            alert("取引先コードを入力してください");
            return;
        }       
        
        if($('#deliveryDate').val() == '' ){
            alert("配送日を入力してください");
            return;
        }       
        
        var productJson = productJsonCreate();
        if(productJson.length == 0 ){
            alert("商品を入力してください");
            return;
        }
        
        var processText = "";
        if(process == 'insert'){
            processText = '登録'
        }else if(process == 'update'){
            processText = '更新'            
        }else if(process == 'delete'){
            processText = '削除'            
        }            
        // 確認ダイアログ
        var result = window.confirm('受注の'+processText+'を行いますがよろしいですか？');
        if(!result){
            return;
        }

        // 受注登録処理呼出
        var form = document.createElement('form');
        var reqProcess = document.createElement('input');       // 処理内容
        var reqOrderCode = document.createElement('input');     // 受注番号
        var reqSupplier = document.createElement('input');      // 取引先コード
        var reqDeliveryDate = document.createElement('input');  // 納品日
        var reqDepartment = document.createElement('input');    // 部署
        var reqOrderUser = document.createElement('input');     // ユーザ
        var reqProducts = document.createElement('input');      // 商品一覧

        form.method = 'POST';
        form.action = '../service/orderRegister.jsp';
        
        reqProcess.type = 'hidden'; // 削除処理のパラメータを付与
        reqProcess.name = 'processRequest';
        reqProcess.value = encodeURIComponent(process);
        form.appendChild(reqProcess);

        reqOrderCode.type = 'hidden';
        reqOrderCode.name = 'orderCode';
        reqOrderCode.value = encodeURIComponent($('#orderCode').val());
        form.appendChild(reqOrderCode);

        reqSupplier.type = 'hidden';
        reqSupplier.name = 'supplierCode';
        reqSupplier.value = encodeURIComponent($('#supplierCode').val());
        form.appendChild(reqSupplier);

        reqDeliveryDate.type = 'hidden';
        reqDeliveryDate.name = 'deliveryDate';
        reqDeliveryDate.value = encodeURIComponent($('#deliveryDate').val());
        form.appendChild(reqDeliveryDate);

        reqDepartment.type = 'hidden';
        reqDepartment.name = 'departmentCode';
        reqDepartment.value = encodeURIComponent($('#departmentCode').val());
        form.appendChild(reqDepartment);

        reqOrderUser.type = 'hidden';
        reqOrderUser.name = 'orderUserCode';
        reqOrderUser.value = encodeURIComponent($('#orderUserCode').val());
        form.appendChild(reqOrderUser);

        reqProducts.type = 'hidden';
        reqProducts.name = 'parameterJson';
        reqProducts.value = encodeURIComponent(JSON.stringify(productJson));
        form.appendChild(reqProducts);

        document.body.appendChild(form);

        form.submit();
    }

    // 登録ボタン処理
    $("#insertButton").click( function() {
        orderRegister('insert');
    });
    
    // 更新ボタン処理
    $("#updateButton").click( function() {
        orderRegister('update');
    });
    
    // 削除ボタン処理
    $("#deleteButton").click( function() {
        orderRegister('delete');
    });
    
    
    // 検索ページ遷移をする前にクライアントでしか管理していない情報を退避させる。
    var pageTransition = function(nextPage){
        // 取引先コードをクッキーに保存
        if($("#supplierCode").val() != ""){
            document.cookie = 'newSupplier=' + encodeURIComponent($("#supplierCode").val());
            document.cookie = 'newSupplierName=' + encodeURIComponent($("#supplierName").val());            
        }
        
        // 納品日をクッキーに保存
        if($("#deliveryDate").val() != ""){
            document.cookie = 'newDeliveryDate=' + encodeURIComponent($("#deliveryDate").val());
        }
                
        // 新規追加行の情報をクッキーに保存
        var productJson = productJsonCreate();
        if(productJson.length != 0 ){
            // JSON形式かつ特殊文字をエンコードしてクッキーに保存
            document.cookie = 'newProRow=' + encodeURIComponent(JSON.stringify(productJson));
        }
        
        // 検索画面に渡すパラメータの設定
        var form = document.createElement('form');
        
        form.method = 'POST';
        form.action = '../view/'+nextPage;

        // 商品検索画面に画面IDを送信
        var request = document.createElement('input');
        request.type = 'hidden'; 
        request.name = 'pageId';
        request.value = 'orderEditPage.jsp';
        form.appendChild(request);
        
        // 受注番号を送信
        if($('#orderCode').val() != ""){
            var request2 = document.createElement('input');
            request2.name = 'orderCode';
            request2.value = $('#orderCode').val();
            form.appendChild(request2);
        }
       
        document.body.appendChild(form);

        form.submit();
    };
    
    // 商品検索ボタン
    $("#searchProductBt").click( function() {        
        pageTransition('productSearchPage.jsp');        
    });

    // 取引先検索ボタン
    $("#searchSupplierButton").click( function() {
        pageTransition('supplierSearchPage.jsp');        
    });

});

