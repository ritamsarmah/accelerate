//
//  StoreManager.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 7/3/21.
//  Copyright © 2021 Ritam Sarmah. All rights reserved.
//

import Cocoa
import StoreKit
import SwiftyStoreKit

open class StoreManager {

    static let shared = StoreManager()

    enum ProductIdentifier {
        static let coffeeTip = "com.ritamsarmah.Accelerate.coffeeTip"
    }

    var localizedTipPrice: String?

    private init() {
        // Cache product information
        SwiftyStoreKit.retrieveProductsInfo([ProductIdentifier.coffeeTip]) { result in
            self.localizedTipPrice = result.retrievedProducts.first?.localizedPrice
        }
    }

    func completeTransactions() {
        // If there are any pending transactions at this point, these will be reported by the completion block so that the app state and UI can be updated.
        // NOTE: This function should only be called once in the app lifetime
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then...
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .deferred, .failed, .purchasing:
                    break
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    func purchaseTip(completion: ((Bool) -> Void)?) {
        SwiftyStoreKit.purchaseProduct(ProductIdentifier.coffeeTip) { result in
            switch result {
            case let .success(purchase):
                Log.debug("Purchase successful: %@", purchase.productId)
                completion?(true)
            case let .error(error):
                Log.error("Purchase failed: %@", error.localizedDescription)

                let title = "Purchase failed"

                switch error.code {
                case .unknown: NSAlert.showAlert(title: title, message: "An unknown error occurred")
                case .clientInvalid: NSAlert.showAlert(title: title, message: "Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: NSAlert.showAlert(title: title, message: "The purchase identifier was invalid")
                case .paymentNotAllowed: NSAlert.showAlert(title: title, message: "The device is not allowed to make the payment")
                case .storeProductNotAvailable: NSAlert.showAlert(title: title, message: "The product is not available anymore")
                case .cloudServicePermissionDenied: NSAlert.showAlert(title: title, message: "Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: NSAlert.showAlert(title: title, message: "Could not connect to the network")
                case .cloudServiceRevoked: NSAlert.showAlert(title: title, message: "User has revoked permission to use this cloud service")
                default: NSAlert.showAlert(error: error)
                }
                completion?(false)
            case let .deferred(purchase):
                Log.debug("Purchase deferred: %@", purchase.productId)
                completion?(false)
            }
        }
    }
}
