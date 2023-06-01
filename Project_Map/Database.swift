//
//  Database.swift
//  Project_Map
//
//  Created by CNTT on 5/26/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Database {
    // mark: database's properties
    private let DB_NAME = "users.sqlite"
    private let DB_Path: String?
    private let Database: FMDatabase?
    
    // mark: table's properties
    // 1. tbMeal
    private let USER_TABLE_NAME = "users"
    private let USER_ID = "_id"
    private let USER_NAME = "_name"
    private let USER_EMAIL = "_email"
    private let USER_PASS = "_pass"
    
    // mark: Contructor
    init() {
        // Lay duong dan cua cac thu muc trong ung dung IOS
        let directeries = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        
        // khoi tao chon DB_PATH
        DB_Path = directeries[0] + "/" + DB_NAME
        
        // khoi tao doi tuong Database
        Database = FMDatabase(path: DB_Path)
        
        // kiem tra su thanh cong khi khoi tao database
        if Database != nil {
            os_log("Khoi tao du lieu thanh cong")
            // Tao bang cho co so du lieu
            let _ = tablesCreation()
        } else {
            os_log("Khong the khoi tao du lieu")
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    // mark: Dinh nghia cac ham Primitives
    ///////////////////////////////////////////////////////////////////////////////////
    
    // 1. kiem tra su ton tai cua Databse
    private func isDatabaseExist() -> Bool {
        return (Database != nil)
    }
    // 2. mo Database
    private func open() -> Bool {
        var ok = false
        
        if isDatabaseExist() {
            if Database!.open() {
                ok = true
                os_log("Mo co so du lieu thanh cong")
            } else {
                os_log("Khong the mo co so du lieu")
            }
        }
        
        return ok
    }
    // 3. dong Database
    private func close() -> Bool {
        var ok = false
        
        if isDatabaseExist() {
            if Database!.close() {
                ok = true
                os_log("Dong co so du lieu thanh cong")
            } else {
                os_log("Khong the dong co so du lieu")
            }
        }
        
        return ok
    }
    // 4. tao cac bang du lieu
    private func tablesCreation() -> Bool {
        var ok = false
        
        if open() {
            // B1: Xay dung cau lenh sql
            let sql = """
            CREATE TABLE \(USER_TABLE_NAME)
            (
                \(USER_ID) INTEGER PRIMARY KEY AUTOINCREMENT,
                \(USER_NAME) TEXT,
                \(USER_EMAIL) TEXT UNIQUE,
                \(USER_PASS) TEXT
            )
            """
            // Thuc thi cau lenh sql
            if Database!.executeStatements(sql) {
                ok = true
                os_log("Tao bang du lieu thanh cong")
            } else {
                os_log("Khong the tao bang")
            }
            
            let _ = close()
            
        }
        
        return ok
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    // mark: Dinh nghia cac ham API
    ///////////////////////////////////////////////////////////////////////////////////
    
    // 1. Ghi bien user vao API
    public func insert(user: User) -> Bool {
        var ok = false
        
        if open() {
            // Xay dung cau lenh sql
            let sql = "INSERT INTO \(USER_TABLE_NAME)(\(USER_NAME), \(USER_EMAIL), \(USER_PASS)) VALUES (?,?,?)"
            // Thuc thi cau lenh sql
            if Database!.executeUpdate(sql, withArgumentsIn: [user.getName(), user.getEmail(), user.getPass()]) {
                ok = true
                os_log("Them du lieu vao database thanh cong")
            } else {
                os_log("Khong the them du lieu vao database")
            }
            
            let _ = close()
        }
        
        return ok
    }
    
    // 2. Doc toan bo user tu co so du lieu ve man hinh login cua tableView
    public func getAllUser() {
        if open() {
            var result:FMResultSet?
            // cau lenh sql
            let sql = "SELECT * FROM \(USER_TABLE_NAME)"
            
            do {
                // thuc thi cau lenh sql
                result = try Database!.executeQuery(sql, values: nil)
            }
            catch {
                os_log("Khong the doc user database")
            }
            
            // xy li du lieu doc ve
            if let result = result {
                while (result.next()) {
                    let name = result.string(forColumn: USER_NAME) ?? ""
                    let email = result.string(forColumn: USER_EMAIL) ?? ""
                    let pass = result.string(forColumn: USER_PASS) ?? ""
                    
                    // Tao bien user tu du lieu doc ve
                    if let user = User(name: name, email: email, pass: pass) {
//                        users.append(user)
                        print(user.print())
                    }
                }
            }
            
            let _ = close()
        }
    }
    
    // 3. Lay user dua vao email va password tu co so du lieu
    public func getUserByEmail(email: String, pass: String) -> [User] {
        var users: [User] = []
        if open() {
            var result:FMResultSet?
            // cau lenh sql
            let sql = "SELECT * FROM \(USER_TABLE_NAME) WHERE \(USER_EMAIL) = ? AND \(USER_PASS) = ?"
            let value = [email, pass]
            do {
                // thuc thi cau lenh sql
                result = try Database!.executeQuery(sql, values: value)
            }
            catch {
                os_log("Khong the doc user database")
            }
            // xy li du lieu doc ve
            if let result = result {
                while (result.next()) {
                    let name = result.string(forColumn: USER_NAME) ?? ""
                    let email = result.string(forColumn: USER_EMAIL) ?? ""
                    let pass = result.string(forColumn: USER_PASS) ?? ""
                    
                    // Tao bien user tu du lieu doc ve
                    if let user = User(name: name, email: email, pass: pass) {
                        users.append(user)
                    }
                }
            }
            let _ = close()
        }
        return users
    }
}
