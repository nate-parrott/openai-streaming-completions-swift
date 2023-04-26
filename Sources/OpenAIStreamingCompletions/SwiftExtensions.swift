//
//  File.swift
//  
//
//  Created by Michel Storms on 26/04/2023.
//

import Foundation

extension URLRequest {
    /// Print request to console for debugging.
    func debug() {
        print("\(self.httpMethod!) \(self.url!)")
        print("Headers:")
        print(self.allHTTPHeaderFields!)
        print("Body:")
        print(String(data: self.httpBody ?? Data(), encoding: .utf8)!)
    }
}
