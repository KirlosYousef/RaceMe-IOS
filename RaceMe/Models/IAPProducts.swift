//
//  IAPProducts.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 20..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import StoreKit

class IAPProducts {
    
    var products = [SKProduct]()
    
    func getProduct(containing keyword: String) -> SKProduct? {
        return products.filter { $0.productIdentifier.contains(keyword) }.first
    }
}
