//
//  Bool+Comparable.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 10.08.2022.
//

import Foundation

extension Bool: @retroactive Comparable {
    static public func < (lhs: Bool, rhs: Bool) -> Bool {
        return lhs.description < rhs.description
    }
    
    static public func == (lhs: Bool, rhs: Bool) -> Bool {
        return lhs.description == rhs.description
    }
}
