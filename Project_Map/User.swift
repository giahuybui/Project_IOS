//
//  User.swift
//  Project_Map
//
//  Created by CNTT on 5/26/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import UIKit

class User {
    private var name:String
    private var email:String
    private var pass:String
    
    // Mark: Contructors
    init?(name:String, email:String, pass:String) {
        
        // kiem tra dieu kien tao doi tuong user
        if name.isEmpty && email.isEmpty && pass.isEmpty {
            return nil
        }
        
        // khoi gan gia tri cho cac bien thanh phan
        self.name = name
        self.email = email
        self.pass = pass
    }
    
    // getter and setter
    // Getter
    public func getName() -> String {
        return name
    }
    public func getEmail() -> String {
        return email
    }
    public func getPass() -> String {
        return pass
    }
    public func print() -> String {
        return "name: \(name), email: \(email), pass: \(pass)"
    }
    
    // Setter
    
}
