//
//  GeneralView.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 9/6/21.
//

import Defaults
import SwiftUI

struct GeneralView: View {

    @Default(.defaultRate) private var defaultRate: Double
    @Default(.minimumRate) private var minimumRate: Double
    @Default(.maximumRate) private var maximumRate: Double

    @Default(.snackbarLocation) private var snackbarLocation: SnackbarLocation

    @State private var isAlertPresented: Bool = false
    @State private var alertInfo: AlertInfo! {
        didSet {
            isAlertPresented = alertInfo != nil
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    // FIXME: Restoring general settings doesn't update number text fields (not handling state with bindings correctly)
                    NumberTextField(
                        title: "Default Speed",
                        value: $defaultRate,
                        placeholder: 1,
                        formatter: Shortcut.Action.rateFormatter
                    )

                    NumberTextField(
                        title: "Minimum Speed",
                        value: $minimumRate,
                        placeholder: 0.25,
                        formatter: Shortcut.Action.rateFormatter
                    ) { newMinimumRate, completion in
                        if newMinimumRate.doubleValue > maximumRate {
                            completion(NSNumber(value: minimumRate))
                            alertInfo = AlertInfo(
                                title: "Invalid Minimum Speed",
                                message: "The minimum speed must be less than the maximum speed of \(Shortcut.Action.rateFormatter.string(from: Defaults[.maximumRate]))",
                                primaryButtonText: "OK",
                                primaryButtonType: .cancel
                            )
                        } else {
                            completion(newMinimumRate)
                        }
                    }

                    NumberTextField(
                        title: "Maximum Speed",
                        value: $maximumRate,
                        placeholder: 16,
                        formatter: Shortcut.Action.rateFormatter
                    ) { newMaximumRate, completion in
                        if newMaximumRate.doubleValue < minimumRate {
                            completion(NSNumber(value: maximumRate))
                            alertInfo = AlertInfo(
                                title: "Invalid Maximum Speed",
                                message: "The maximum speed must be greater than the minimum speed of \(Shortcut.Action.rateFormatter.string(from: Defaults[.minimumRate]))",
                                primaryButtonText: "OK",
                                primaryButtonType: .cancel
                            )
                        }
                    }
                }

                Section(footer: Text("Each shortcut must also have notifications enabled to show.")) {
                    Picker("Notification Location", selection: $snackbarLocation) {
                        ForEach(SnackbarLocation.allCases, id: \.rawValue) { location in
                            Text(location.description)
                                .tag(location)
                        }
                    }
                    .pickerStyle(.automatic)
                }

                Section {
                    NavigationLink("About", destination: AboutView())
                    NavigationLink("Getting Started", destination: TutorialView())
                    NavigationLink("Tip Jar", destination: TipView())
                }

                Section {
                    Button("Reset Settings", role: .destructive) {
                        isAlertPresented = true
                        alertInfo = AlertInfo(
                            title: "Reset Settings?",
                            message: "This option will reset your general settings, such as default speed, etc.",
                            primaryButtonText: "Cancel",
                            primaryButtonType: .cancel,
                            secondaryButtonText: "Reset",
                            secondaryButtonType: .destructive,
                            secondaryButtonAction: { Defaults.reset(Defaults.Keys.allGeneralKeys) }
                        )
                    }
                }
            }

            .alert(isPresented: $isAlertPresented) {
                Alert(alertInfo: alertInfo)
            }
            .navigationTitle(Text("General"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView()
    }
}

class GeneralViewController: UIHostingController<GeneralView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: GeneralView())
    }
}
