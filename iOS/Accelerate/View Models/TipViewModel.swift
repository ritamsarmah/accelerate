//
//  TipViewModel.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/18/22.
//

import Foundation
import StoreKit
import SwiftUI

public enum StoreError: Error {
    case failedVerification
}

extension TipView {

    class ViewModel: ObservableObject {

        @Published public var isPurchasing: Bool = false
        @Published public var displayPrice: String = ""
        @Published public var confettiCounter = 0

        private var tip: Product? = nil
        private var updateListenerTask: Task<Void, Error>? = nil

        private let identifier = "com.ritamsarmah.Accelerate.coffeeTip"

        init() {
            self.updateListenerTask = listenForTransactions()

            Task {
                await requestProduct()
            }
        }

        func openReviewURL() {
            UIApplication.shared.open(URL(string: "https://apps.apple.com/app/id1459809092?action=write-review")!)
        }

        func requestProduct() async {
            do {
                tip = try await Product.products(for: [identifier]).first
                displayPrice = " (\(tip!.displayPrice))"
            } catch {
                AlertInfo.showAlert(.tipLoadFailed(error: error))
            }
        }

        func purchaseTip() async {
            guard let tip else { return }

            isPurchasing = true

            do {
                let result = try await tip.purchase()

                switch result {
                case let .success(verification):
                    let transaction = try verifyTransaction(verification)

                    // Show confetti to user
                    DispatchQueue.main.async {
                        self.isPurchasing = false
                        self.confettiCounter += 1
                    }

                    await transaction.finish()
                default:
                    DispatchQueue.main.async { self.isPurchasing = false }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isPurchasing = false
                    AlertInfo.showAlert(.tipPurchaseFailed(error: error))
                }
            }
        }

        private func verifyTransaction<T>(_ result: VerificationResult<T>) throws -> T {
            switch result {
            case .unverified:
                // StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
                throw StoreError.failedVerification
            case let .verified(safe):
                // If the transaction is verified, unwrap and return it.
                return safe
            }
        }

        private func listenForTransactions() -> Task<Void, Error> {
            Task.detached {
                // Iterate through any transactions which didn't come from a direct call to `purchase()`.
                for await result in Transaction.updates {
                    do {
                        let transaction = try self.verifyTransaction(result)
                        await transaction.finish()
                    } catch {
                        Log.shared.error("Transaction failed verification")
                    }
                }
            }
        }
    }

}
