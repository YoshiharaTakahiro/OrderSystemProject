# OrderSystemProject

## ・受発注管理システムプロジェクト
2019年度教員研修で作成したシステムです。  
README.meでは、プロジェクトを導入するための手順を記述します。

## ・開発環境
言語 ：java、JavaScript  
IDE ：NetBeans8.1（GlassFishServer4.1.1）  
DB  ：MySQL8.0  

## ・データベース初期設定
MySQLインストール後、my.iniファイルを編集して文字コードをUTF-8にして下さい。  
```
[mysql]
no-beep

default-character-set=utf8

[mysqld]
~ 省略 ~
# The default character set that will be used when a new schema or table is
# created and no character set is defined
character-set-server=utf8
```
データベースの構成を行います。
```sql

※ここは後程、記述します。
データベース作成
ユーザ作成
テーブル作成
制約作成
テストデータ挿入

```
テストデータは最低限になりますので必要なデータは適宜追加して下さい。  
※UsersテーブルのPASSWORD列はSHA-256でハッシュ化した内容を登録して下さい。  

## ・プロジェクト構成
Webページ  
├ WEB-INF  
│ └ web.xml　：WebAP設定ファイル  
├ css　　　　：CSSファイル用フォルダ  
├ js　　　　 ：JavaScriptファイル用フォルダ  
├ service　　：処理のみ行うjspファイル用フォルダ  
├ view　　　：画面が存在するjspファイル用フォルダ  
└ index.jsp　：indexはログイン画面にリダイレクトします

## ・ログイン画面URL（ローカル環境）
http://localhost:8080/OrderSystemProject/view/loginpage.jsp
