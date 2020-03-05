/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mydb;

import java.sql.*;

/**
 *
 * @author Yoshihara Takahiro
 */
public class DatabeseAccess {
    private String driver;
    private String url;
    private String user;
    private String password;
    private Connection connection;
    private Statement statement;
    private ResultSet resultset;
 
    /**
     * コンストラクタ
     * @param driver ドライバー
     * @param url URL
     * @param user ユーザー名
     * @param password パスワード
     */
    public DatabeseAccess(String driver, String url, String user, String password) {
        this.driver = driver;
        this.url = url;
        this.user = user;
        this.password = password;
    }
 
    /**
     * 引数なしのコンストラクタ
     * 既定値を使用する
     */
    public DatabeseAccess() {
        // Mysql8以前
        //driver = "com.mysql.jdbc.Driver";
        //url = "jdbc:mysql://localhost:3306/omdb";

        // Mysql8
        driver = "com.mysql.cj.jdbc.Driver";
        url = "jdbc:mysql://localhost:3306/omdb?allowPublicKeyRetrieval=true&useSSL=false&characterEncoding=utf8&serverTimezone=GMT%2B9:00&rewriteBatchedStatements=true";
        user = "omuser";
        password = "omuser";
    }
 
    /**
     * データベースへの接続を行う
     */
    public synchronized void open() throws Exception {
        Class.forName(driver);
        connection = DriverManager.getConnection(url, user, password);
        connection.setAutoCommit(false);
        statement = connection.createStatement();
    }
 
    /**
     * SQL 文を実行した結果の ResultSet を返す
     * @param sql SQL 文
     */
    public ResultSet getResultSet(String sql) throws Exception {
        if ( statement.execute(sql) ) {
            return statement.getResultSet();
        }
        return null;
    }
 
    /**
     * SQL 文の実行
     * @param sql SQL 文
     */
    public void execute(String sql) throws Exception {
        statement.execute(sql);
    }
    
    /**
     * トランザクションの確定
     * @throws Exception 
     */
    public void commit() throws Exception{
        connection.commit();
    }
    
    /**
     * トランザクションの取消
     * @throws Exception 
     */
    public void rollback() throws Exception{
        connection.rollback();        
    }
 
    /**
     * データベースへのコネクションのクローズ
     */
    public synchronized void close() throws Exception {
        if ( resultset != null ) resultset.close();
        if ( statement != null ) statement.close();
        if ( connection != null ) connection.close();
    }
}
