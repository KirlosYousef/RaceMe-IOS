//
//  Purchase.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 05. 20..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyJSON

class Purchasing: ObservableObject{
    
    @Published var isLoading: Bool = false
    @Published var errorMsg: String? = nil
    
    func purchase(product: SKProduct, handler: @escaping (Int) -> Void){
        if !IAPManager.shared.canMakePayments() {
            handler(-1)
        } else {
            isLoading = true
            
            // Will try to reconnect first to make sure of an updated active session.
            AppDelegate._bc.reconnect({serviceName, serviceOperation, jsonData, cbObject in
                
                IAPManager.shared.buy(product: product) { (result) in
                    switch result {
                    case .success(_): self.updateGameDataWithPurchasedProduct(product: product, handler: { tokensBalance in
                        handler(tokensBalance)
                    })
                    case .failure(let error): self.errorMsg = error.localizedDescription
                    }
                    self.isLoading = false
                }
                
            }, errorCompletionBlock: {serviceName, serviceOperation, first, Second, jsonData, cbObject in
                self.errorMsg = "There is some problem with your session or internet, please resart the app or try again later!"
            }, cbObject: nil)
        }
    }
    
    func restorePurchases() {
        self.isLoading = true
        IAPManager.shared.restorePurchases { (result) in
            switch result {
            case .success(let success):
                if success {
                    self.didFinishRestoringPurchasedProducts()
                } else {
                    self.didFinishRestoringPurchasesWithZeroProducts()
                }
                
            case .failure(let error): self.errorMsg = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func updateGameDataWithPurchasedProduct(product: SKProduct, handler: @escaping (Int) -> Void){
        print(product.localizedTitle, "Has been purchased successfully!")
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptURL).base64EncodedString() else {
            return
        }
        
        let formatedReceipt: String = "{\"receipt\":\"\(receiptData)\"}"
        
        AppDelegate._bc.appStoreService.verifyPurchase("itunes", receiptData: formatedReceipt, completionBlock: { (serviceName, serviceOperation, jsonData, cbObject) in
            if let jsonData = jsonData?.data(using: String.Encoding.utf8, allowLossyConversion: false){
                
                let json = JSON(jsonData)
                let data = json["data"]
                
                let transactionDetails = data["transactionSummary"]["transactionDetails"].arrayValue
                for trans in transactionDetails{
                    if trans["itemId"].stringValue == "AdFree"{
                        UserDefaults.standard.setIsAdFree(value: true)
                    }
                }
                
                let tokensBalance = data["currency"]["Tokens"]["balance"].intValue
                
                handler(tokensBalance)
            }
            
        }, errorCompletionBlock: onPurchaseVerifyFailed, cbObject: nil)
        
    }
    
    func onPurchaseVerifyFailed(serviceName:String?, serviceOperation:String?, statusCode:Int?, reasonCode:Int?, jsonError:String?, cbObject: NSObject?){
        print(jsonError?.description as Any)
    }
    
    func didFinishRestoringPurchasedProducts(){
        if IAPManager.shared.totalRestoredPurchases != 0 {
            UserDefaults.standard.setIsAdFree(value: true)
            print("The user restored the Ad-Free option.")
        }
    }
    
    func didFinishRestoringPurchasesWithZeroProducts(){
        print("No products to restore!")
        errorMsg = ("No products to restore!")
    }
}
