//
//  TipView.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/18/22.
//

import ConfettiSwiftUI
import StoreKit
import SwiftUI

struct TipView: View {

    @ObservedObject private var viewModel = ViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            VStack(alignment: .center, spacing: 20) {
                if viewModel.isPurchasing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding([.bottom], 8)
                } else {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.accentColor)
                        .font(.title)
                }

                Text("Thanks for using Accelerate!")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("If you are enjoying this app, leaving a review or tip helps support future work and is greatly appreciated!")
                    .frame(maxWidth: 320)
            }

            HStack {
                Button("Tip\(viewModel.displayPrice)") {
                    Task {
                        await viewModel.purchaseTip()
                    }
                }
                Button("Leave a Review") {
                    viewModel.openReviewURL()
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .disabled(viewModel.isPurchasing)
        }
        .multilineTextAlignment(.center)
        .padding()
        .navigationBarTitle("", displayMode: .inline)
        .confettiCannon(counter: $viewModel.confettiCounter)
    }
}

struct TipView_Previews: PreviewProvider {
    static var previews: some View {
        TipView()
    }
}
