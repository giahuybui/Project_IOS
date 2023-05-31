//
//  Recently.swift
//  Project_Map
//
//  Created by CNTT on 5/31/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import Foundation

class Recently {
    private var recent: [String] = []
    
    func getRecent() -> [String] {
        return recent
    }
    
    func setRecent(_ message: String) {
        recent = [message]
    }
}
