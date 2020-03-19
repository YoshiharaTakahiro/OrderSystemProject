# OrderSystemProject

### ・受発注管理システムプロジェクト
2019年度教員研修で作成したシステムです。  
README.meでは、プロジェクトを導入するための手順を記述します。

### ・開発環境
言語 ：java、JavaScript  
IDE ：NetBeans8.1（GlassFishServer4.1.1）  
DB  ：MySQL8.0  

### ・データベース初期設定
MySQLインストール後、my.iniファイルを編集して文字コードをUTF-8にして下さい。  
```
[mysql]
no-beep

default-character-set=utf8  #この行を追加 or 変更

[mysqld]
~ 省略 ~
# The default character set that will be used when a new schema or table is
# created and no character set is defined
character-set-server=utf8  #この行を追加 or 変更
```

データベースの構成スクリプトの実行を行います。  
CREATE_OMDB.sqlファイルが格納されているディレクトリでMySQLにrootユーザでログインしてスクリプトを実行する。
```sql
mysql -u root -p

mysql> .\ CREATE_OMDB.sql
```
※文字化けする場合はCREATE_OMDB.sqlの内容を直接コピー＆ペーストして実行してください。

テストデータは最低限になりますので必要なデータは適宜追加して下さい。  
※UsersテーブルのPASSWORD列はSHA-256でハッシュ化した内容を登録して下さい。  

### ・プロジェクト構成
Webページ  
├ WEB-INF  
│ └ web.xml　：WebAP設定ファイル  
├ css　　　　：CSSファイル用フォルダ  
├ js　　　　 ：JavaScriptファイル用フォルダ  
├ service　　：処理のみ行うjspファイル用フォルダ  
├ view　　　：画面が存在するjspファイル用フォルダ  
└ index.jsp　：indexはログイン画面にリダイレクトします

### ・ログイン画面URL（ローカル環境）
http://localhost:8080/OrderSystemProject/view/loginpage.jsp

### ・汎用マスタコードリスト
名称       |  DIVISION | GENERAL_CODE | GENERAL_NAME      |
-----------|-----------|--------------|-------------------|
ブランド    |  BLD      | AC           | テストブラントAC  |
ブランド    |  BLD      | HK           | テストブラントHK  |
ブランド    |  BLD      | HKW          | テストブラントHKW |
ブランド    |  BLD      | KT           | テストブラントKT  |
ブランド    |  BLD      | MZ           | テストブラントMZ  |
ブランド    |  BLD      | RK           | テストブラントRK  |
ブランド    |  BLD      | SN           | テストブラントSN  |
ブランド    |  BLD      | ZN           | テストブラントZN  |
ブランド    |  BLD      | ZY           | テストブラントZY  |
クラス      |  CLS      | 1            | 婦人              |
クラス      |  CLS      | 2            | 紳士              |
クラス      |  CLS      | 3            | 子供              |
クラス      |  CLS      | 4            | ユニセックス      |
カラー      |  COR      | 0            | 白                |
カラー      |  COR      | 1            | 黒                |
カラー      |  COR      | 2            | 茶                |
カラー      |  COR      | 3            | 赤                |
カラー      |  COR      | 4            | 橙                |
カラー      |  COR      | 5            | 黄                |
カラー      |  COR      | 6            | 緑                |
カラー      |  COR      | 7            | 青                |
カラー      |  COR      | 8            | 紫                |
カラー      |  COR      | 9            | その他            |
素材        |  MTL      | 1            | 馬革              |
素材        |  MTL      | 10           | 帆布              |
素材        |  MTL      | 11           | 綿                |
素材        |  MTL      | 12           | デニム            |
素材        |  MTL      | 13           | ナイロン          |
素材        |  MTL      | 14           | レース            |
素材        |  MTL      | 2            | 牛革              |
素材        |  MTL      | 3            | 豚革              |
素材        |  MTL      | 4            | 蛇革              |
素材        |  MTL      | 5            | 山羊革            |
素材        |  MTL      | 6            | ゴート革          |
素材        |  MTL      | 7            | 水牛              |
素材        |  MTL      | 8            | 天然皮革          |
素材        |  MTL      | 9            | 合成皮革          |
タイプ      |  TYP      | 1            | 定番              |
タイプ      |  TYP      | 2            | スポット          |
タイプ      |  TYP      | 3            | 特価              |
