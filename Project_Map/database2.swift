//
//  database.swift
//  Project_Map
//
//  Created by CNTT on 5/23/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

class Database2 {
    
    public var userName: NSString?
    public var userEmail: NSString?
    public var password: NSString?
    
    // khoi tao database
    func cretaDatabase() -> OpaquePointer {
        // Khởi tạo kết nối tới cơ sở dữ liệu SQLite
        var db: OpaquePointer? = nil
        
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mydatabase.sqlite")
        
        if sqlite3_open(databaseURL.path, &db) == SQLITE_OK {
            print("Kết nối tới cơ sở dữ liệu thành công")
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Lỗi khi mở kết nối tới cơ sở dữ liệu: \(errorMessage)")
        }
        
        return (db ?? nil)!
        
    }

    func createUser(_ db: OpaquePointer) {
        
        // Tạo bảng "user"
        let createTableQuery = """
                    CREATE TABLE IF NOT EXISTS user (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT,
                        email TEXT UNIQUE,
                        pass TEXT
                    );
                """
        
        var createTableStatement: OpaquePointer? = nil
        //        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Đã tạo bảng 'user'")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Lỗi khi tạo bảng 'user': \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Lỗi khi chuẩn bị truy vấn SQL: \(errorMessage)")
        }
    }
    
    func setUser(_ db: OpaquePointer) {
        // Chèn dữ liệu người dùng
        let insertUserQuery = """
                INSERT INTO user (name, email, pass)
                VALUES (?, ?, ?);
            """
        
        var insertUserStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertUserQuery, -1, &insertUserStatement, nil) == SQLITE_OK {
            let name: NSString = userName ?? ""
            let email: NSString = userEmail ?? ""
            let pass: NSString = password ?? ""
            
            sqlite3_bind_text(insertUserStatement, 1, name.utf8String, -1, nil)
            sqlite3_bind_text(insertUserStatement, 2, email.utf8String, -1, nil)
            sqlite3_bind_text(insertUserStatement, 3, pass.utf8String, -1, nil)
            
            if sqlite3_step(insertUserStatement) == SQLITE_DONE {
                print("Dữ liệu người dùng đã được chèn thành công")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Lỗi khi chèn dữ liệu người dùng: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Lỗi khi chuẩn bị truy vấn SQL: \(errorMessage)")
        }
        
        sqlite3_finalize(insertUserStatement)
    }
    
    func getUser(_ db: OpaquePointer) {
        var statement: OpaquePointer? = nil
        let queryString = "SELECT * FROM user"
        
        if sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let email = String(cString: sqlite3_column_text(statement, 2))
                let pass = String(cString: sqlite3_column_text(statement, 3))
                print("ID: \(id), Name: \(name), Email: \(email), Password: \(pass)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Lỗi khi chuẩn bị truy vấn SQL: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        
    }
    
    func admin(_ db: OpaquePointer) {
        // Chèn dữ liệu người dùng
        let insertUserQuery = """
                INSERT INTO user (name, email, pass)
                VALUES (?, ?, ?);
            """
        
        var insertUserStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertUserQuery, -1, &insertUserStatement, nil) == SQLITE_OK {
            let name: NSString = "admin"
            let email: NSString = "admin@gmail.com"
            let pass: NSString = "123456"
            
            sqlite3_bind_text(insertUserStatement, 1, name.utf8String, -1, nil)
            sqlite3_bind_text(insertUserStatement, 2, email.utf8String, -1, nil)
             sqlite3_bind_text(insertUserStatement, 3, pass.utf8String, -1, nil)
            
            if sqlite3_step(insertUserStatement) == SQLITE_DONE {
                print("Dữ liệu người dùng đã được chèn thành công")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Lỗi khi chèn dữ liệu người dùng: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Lỗi khi chuẩn bị truy vấn SQL: \(errorMessage)")
        }
        
        sqlite3_finalize(insertUserStatement)
    }
    
//    sqlite3_close(db)
    
    func dropdatabase() {
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mydatabase.sqlite")
        
        do {
            try FileManager.default.removeItem(at: databaseURL)
            print("Đã xóa cơ sở dữ liệu thành công")
        } catch {
            print("Lỗi khi xóa cơ sở dữ liệu: \(error)")
        }
    }
}
