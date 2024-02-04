//
//  AboutView.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/6/21.
//

import Foundation
import SwiftUI

struct AboutView: View {
    var body: some View {
        Form {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 16) {
                    Image(uiImage: UIImage(named: "Icon")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64, alignment: .center)
                    VStack(alignment: .center, spacing: 3) {
                        Text("Accelerate for iOS")
                            .font(.headline)
                        Group {
                            Text("Ritam Sarmah")
                            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                        }
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    }
                }
                Spacer()
            }
            .listRowBackground(Color.clear)

            Section {
                Link("Contact Support", destination: URL(string: "mailto:hello@ritam.me")!)
                Link("Privacy Policy", destination: URL(string: "https://ritam.me/projects/accelerate/privacy")!)
                Link("FAQ", destination: URL(string: "https://ritam.me/projects/accelerate/faq-ios")!)
            }

            Section {
                Link("Accelerate for Mac", destination: URL(string: "https://apps.apple.com/app/id1459809092?mt=12")!)
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
