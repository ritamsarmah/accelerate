//
//  TutorialView.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 11/28/21.
//

import Defaults
import SwiftUI

struct TutorialView: View {

    @Default(.shortcuts) private var shortcuts: [Shortcut]

    let maxWidth = 512.0

    var body: some View {
        TabView {
            welcomeView
            enableView
            popupView
            keyboardView
            faqView
        }
        .tabViewStyle(PageTabViewStyle())
        .padding()
        .navigationBarTitle("", displayMode: .inline)
    }

    var welcomeView: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(uiImage: UIImage(named: "Icon")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64, alignment: .center)

            Text("Welcome to Accelerate")
                .font(.title2)
                .fontWeight(.bold)

            Text("Accelerate is a Safari extension with powerful, customizable features for controlling video playback. Adjust playback speed, skip with custom intervals, toggle Picture-in-Picture, and more!")
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: maxWidth)
    }

    var enableView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("How to Enable Accelerate")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "gear")
                    Text("Open the **Settings** app")
                }

                HStack {
                    Image(systemName: "safari")
                    Text("Select **Safari**")
                }

                HStack {
                    Image(systemName: "puzzlepiece.extension")
                    Text("Select **Extensions**")
                }

                HStack {
                    Image(systemName: "app.badge.checkmark")
                    Text("Select **Accelerate**")
                }

                HStack {
                    Image(systemName: "switch.2")
                    Text("Turn Accelerate **On**")
                }

                HStack {
                    Image(systemName: "globe")
                    Text("Set **All Websites** to **Allow**")
                }
            }
        }
        .frame(maxWidth: maxWidth)
    }

    var popupView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Using Playback Shortcuts")
                .font(.title2)
                .fontWeight(.bold)

            Text("You can trigger shortcuts from the extension popup menu in Safari. Tap the \(Image(systemName: "puzzlepiece.extension")) in Safari's toolbar and select **Accelerate** to access your shortcuts. These can be customized in the **Shortcuts** tab.")
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: maxWidth)
    }

    var keyboardView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Keyboard Shortcuts")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("You can also trigger shortcuts mapped to a key on your keyboard. Here are your current keyboard shortcuts:")
                .multilineTextAlignment(.center)

            VStack(alignment: .leading) {
                ForEach(shortcuts) { shortcut in
                    if let keyInput = shortcut.keyInput, !keyInput.isEmpty {
                        Text("**\(keyInput)** → \(shortcut.description)")
                    }
                }
            }
        }
        .frame(maxWidth: maxWidth)
    }

    var faqView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("🎉")
                .font(.title)

            Text("You're All Set!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Accelerate has many other features, including a blocklist, custom default speed, and more. If you have any questions, check out the [FAQ](https://ritam.me/projects/accelerate/faq-ios) or contact support.")

            Text("Accelerate is also available for download on the Mac App Store.")
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: maxWidth)
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
