//
//  Sequence.swift
//  User
//
//  Created by CSS on 06/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

extension Sequence {
    
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
    
}
