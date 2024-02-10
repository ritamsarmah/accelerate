//
//  NumberTextField.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 11/26/21.
//

import SwiftUI

struct NumberTextField<Value>: View {

    let title: String

    let placeholder: String

    let formatter: NumberFormatter

    typealias Validator = ((NSNumber, (NSNumber) -> Void) -> Void)?
    var validator: Validator

    @State private var text: String

    @Binding private var value: Value {
        didSet { text = Self.string(from: value, formatter: formatter) }
    }

    init(title: String, value: Binding<Value>, placeholder: Value, formatter: NumberFormatter, validator: Validator = nil) {
        self.init(title: title, value: value, placeholder: Self.string(from: placeholder, formatter: formatter), formatter: formatter, validator: validator)
    }

    init(title: String, value: Binding<Value>, placeholder: String, formatter: NumberFormatter, validator: Validator = nil) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.formatter = formatter
        self.validator = validator
        self._text = State(initialValue: Self.string(from: value.wrappedValue, formatter: formatter))
    }

    private static func string(from value: Value, formatter: NumberFormatter) -> String {
        if let intValue = value as? Int {
            formatter.string(from: intValue)
        } else if let intValue = value as? Int? {
            formatter.string(from: intValue)
        } else if let doubleValue = value as? Double {
            formatter.string(from: doubleValue)
        } else if let doubleValue = value as? Double? {
            formatter.string(from: doubleValue)
        } else if let numberValue = value as? NSNumber {
            formatter.string(from: numberValue)
        } else if let numberValue = value as? NSNumber? {
            formatter.string(from: numberValue)
        } else {
            fatalError("Unsupported type")
        }
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField(title, text: $text, prompt: Text(placeholder))
                .keyboardType(.numbersAndPunctuation)  // Use numbers and punctuation keyboard since it has a submit button to save
                .submitLabel(.done)
                .multilineTextAlignment(.trailing)
                .onSubmit {
                    guard var newValue = formatter.number(from: text) else {
                        text = Self.string(from: value, formatter: formatter)
                        return
                    }

                    // Run custom validation on newValue and replace if a final value is provided
                    validator?(newValue) { newValue = $0 }

                    if _value is Binding<Int> || _value is Binding<Int?> {
                        value = newValue.intValue as! Value
                    } else if _value is Binding<Double> || _value is Binding<Double?> {
                        value = newValue.doubleValue as! Value
                    } else if _value is Binding<NSNumber> || _value is Binding<NSNumber?> {
                        value = newValue as! Value
                    }
                }
        }
    }
}
