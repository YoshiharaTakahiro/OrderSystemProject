 //登録ボタン→新規登録画面に
 const insertButton = document.getElementById('insertButton')
 insertButton.addEventListener('click', function () {

   location.href = './orderEditPage.jsp'
 })


 //受注番号で受注明細（登録）へ　いずれこっちへ//var f = document.createElement('form');
 function codeClick(i) {
   document.forms.f1.orderCode.value = i;
   var f = document.forms["f1"];
   f.method = "POST";
   f.submit();
   return true;
 }

 //受注番号から当該の受注明細（編集）へ
 // class属性値が「orderE」である複数の要素を配列変数に格納
 function toEditPage() {
   let odr = document.getElementsByClassName('orderE')
   // 配列化変数「odr」の要素数分ループ処理
   for (let i = 0; i < odr.length; i++) {
     // クリックイベントにイベントリスナをバインド　
     //console.log("受注コード:" + odr[i].innerHTML)
     odr[i].addEventListener('mouseup', function () {
       //とりあえずgetで実装している→postにして関数化
       //location.href='./orderEditPage.jsp?orderNo='　+ odr[i].innerHTML
       var code = odr[i].innerHTML
       codeClick(code)
       //console.log('running!')
     })
   }
 }

 //ページ読み込み時にイベント(受注明細（編集）へ)を割り当て
 toEditPage()


 //後で戻すために最初に表示したものを読み込み時に取る,DOMの直ではないので参照で変化しない、念の為constで宣言
 const const_itemRecord = document.getElementById('itemRecord').innerHTML
 //いろいろDOM操作するために取得
 let itemRecord = document.getElementById('itemRecord')
 let orderCodeBox = document.getElementById('orderCodeBox')
 let orderDateBox = document.getElementById('orderDateBox')
 let supplierCodeBox = document.getElementById('supplierCodeBox')

 // 受注IDのテキストボックスでのイベント
 //change(エンターキーもしくはフォーカス外れる)をリッスンして動く
 orderCodeBox.addEventListener('change', function () {
   let num = orderCodeBox.value
   if (!num) {
     itemRecord.innerHTML = const_itemRecord
   } else if (eval(num) && document.getElementById(num) != null) {

     let tmp = document.getElementById(num).parentNode.innerHTML
     itemRecord.innerHTML = tmp
     //let tmp2 = tmp.parentNode.parentNode.innerHTML
     console.log(tmp)
   } else {
     itemRecord.innerHTML = "該当案件なし．"
   }
 })



 //年月のテキストボックスでのイベント　focus → change → input
 orderDateBox.addEventListener('focus', function () {
 //changeをリッスンして動く →blur
  orderDateBox.addEventListener('blur', function () {
    let num = orderDateBox.value
    console.log(num)
    if (num == "") {
      itemRecord.innerHTML = const_itemRecord
    } else if (document.getElementsByClassName(num) != null) {
      let orderDate = document.getElementsByClassName(num)
      
      let tmp = "<tr>"+orderDate[0].parentNode.innerHTML+"</tr>"
        //for (let i = 1; i < orderDate.length; i++) {
        //  tmp += "<tr>"+orderDate[i].parentNode.innerHTML+"</tr>"             
        //}
      itemRecord.innerHTML = tmp
      console.log(tmp)
    } else {
      itemRecord.innerHTML = "該当案件なし．"
    }

  })
})
 // 取引先IDのテキストボックスでのイベント

 //fucus中のみchangeをリッスンして動く
 supplierCodeBox.addEventListener('change', function () {

   let num = supplierCodeBox.value

   if (!num) {
     itemRecord.innerHTML = const_itemRecord
   } else if (eval(num) && document.getElementsByClassName(num) != null) {
     let supplierCode = document.getElementsByClassName(num)
     //console.log(supplierCode)
     let tmp = "<tr>"+supplierCode[0].parentNode.innerHTML+"</tr>"
     for (let i = 1; i < supplierCode.length; i++) {
      tmp += "<tr>"+supplierCode[i].parentNode.innerHTML+"</tr>"
       //let tmp2 = tmp.parentNode.parentNode.innerHTML
       console.log(tmp)
     }
     itemRecord.innerHTML = tmp
   } else {
     itemRecord.innerHTML = "該当案件なし．"
   }

 })

 //以下、jQuery できたらJSで書きたい→3/6書いた

 // 取引先検索ボタン
 searchSupplierButton.addEventListener('click', function () {
   pageTransition('supplierSearchPage.jsp')
 })


 // 検索ページ遷移をする前にクライアントでしか管理していない情報を退避させる。
 function pageTransition(nextPage) {

   // 検索画面に渡すパラメータの設定
   var form = document.createElement('form');

   form.method = 'POST';
   form.action = '../view/' + nextPage;

   // 商品検索画面に画面IDを送信
   var request = document.createElement('input');
   request.type = 'hidden';
   request.name = 'pageId';
   request.value = 'orderListPage.jsp';
   form.appendChild(request);
   /* 
      // 受注番号を送信
      var request2 = document.createElement('input');
      request2.type = 'hidden';
      form.appendChild(request2);
   */
   document.body.appendChild(form);

   form.submit();
 };