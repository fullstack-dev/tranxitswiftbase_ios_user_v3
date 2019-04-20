//
//  Box.swift
//  MVVMSample
//
//  Created by CSS on 15/02/18.
//  Copyright © 2018 CSS. All rights reserved.
//


import Foundation

class Bind<T> {
  
   typealias Listener = (T?) -> Void
    
    var listener : Listener?
    
    var value : T? {
        
        didSet {
            listener?(value)
        }
    }
    
    init(_ value : T?) {
        self.value = value
    }
    
    func bind(listener : Listener?) {
        
        self.listener = listener
        listener?(value)
        
    }
    
}
