//
//  Shortcut+Action.swift
//  Accelerate
//
//  Created by Ritam Sarmah on 5/21/22.
//

import Foundation

extension Shortcut {
    enum Action: Hashable {
        case speedUp(amount: Double = 0.25)
        case slowDown(amount: Double = 0.25)
        case setRate(Double? = nil) // nil means set to user-configured default speed
        case showRate
        case playOrPause
        case skipForward(seconds: Int = 10)
        case skipBackward(seconds: Int = 10)
        case skipToEnd
        case toggleMute
        case pip
        case fullscreen
    }
}

extension Shortcut.Action: Codable {
    private enum CodingKeys: String, CodingKey {
        case base, speedUpAmount, slowDownAmount, setRateValue, skipForwardSeconds, skipBackwardSeconds
    }

    private enum Base: String, Codable {
        case speedUp, slowDown, setRate, showRate, play, skipForward, skipBackward, skipToEnd, toggleMute, pip, fullscreen
    }

    private struct RateChange: Codable {
        let value: Double
    }

    private struct Rate: Codable {
        let value: Double?
    }

    private struct Seconds: Codable {
        let value: Int
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .speedUp(amount):
            try container.encode(Base.speedUp, forKey: .base)
            try container.encode(RateChange(value: amount), forKey: .speedUpAmount)
        case let .slowDown(amount):
            try container.encode(Base.slowDown, forKey: .base)
            try container.encode(RateChange(value: amount), forKey: .slowDownAmount)
        case let .setRate(rate):
            try container.encode(Base.setRate, forKey: .base)
            try container.encode(Rate(value: rate), forKey: .setRateValue)
        case .showRate:
            try container.encode(Base.showRate, forKey: .base)
        case .playOrPause:
            try container.encode(Base.play, forKey: .base)
        case let .skipForward(seconds):
            try container.encode(Base.skipForward, forKey: .base)
            try container.encode(Seconds(value: seconds), forKey: .skipForwardSeconds)
        case let .skipBackward(seconds):
            try container.encode(Base.skipBackward, forKey: .base)
            try container.encode(Seconds(value: seconds), forKey: .skipBackwardSeconds)
        case .skipToEnd:
            try container.encode(Base.skipToEnd, forKey: .base)
        case .toggleMute:
            try container.encode(Base.toggleMute, forKey: .base)
        case .pip:
            try container.encode(Base.pip, forKey: .base)
        case .fullscreen:
            try container.encode(Base.fullscreen, forKey: .base)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)

        switch base {
        case .speedUp:
            let amount = try container.decode(RateChange.self, forKey: .speedUpAmount)
            self = .speedUp(amount: amount.value)
        case .slowDown:
            let amount = try container.decode(RateChange.self, forKey: .slowDownAmount)
            self = .slowDown(amount: amount.value)
        case .setRate:
            let rate = try container.decode(Rate.self, forKey: .setRateValue)
            self = .setRate(rate.value)
        case .showRate:
            self = .showRate
        case .play:
            self = .playOrPause
        case .skipForward:
            let seconds = try container.decode(Seconds.self, forKey: .skipForwardSeconds)
            self = .skipForward(seconds: seconds.value)
        case .skipBackward:
            let seconds = try container.decode(Seconds.self, forKey: .skipBackwardSeconds)
            self = .skipBackward(seconds: seconds.value)
        case .skipToEnd:
            self = .skipToEnd
        case .toggleMute:
            self = .toggleMute
        case .pip:
            self = .pip
        case .fullscreen:
            self = .fullscreen
        }
    }
}

extension Shortcut.Action: CaseIterable, CustomStringConvertible, CustomDebugStringConvertible {
    static var allCases: [Shortcut.Action] {
        [.speedUp(), .slowDown(), .setRate(), .showRate, .playOrPause, .skipForward(), .skipBackward(), .skipToEnd, .toggleMute, .pip, .fullscreen]
    }

    static var rateFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.minimum = 0.01
        formatter.locale = .current
        #if os(macOS)
            formatter.attributedStringForNil = NSAttributedString(string: "Default")
        #endif
        return formatter
    }

    static var timeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimumIntegerDigits = 1
        formatter.minimum = 0
        formatter.locale = .current
        return formatter
    }
    
    static func ==(lhs: Shortcut.Action, rhs: Shortcut.Action) -> Bool {
        return lhs.description == rhs.description
    }

    var description: String {
        switch self {
        case let .slowDown(amount), let .speedUp(amount):
            let formattedAmount = Shortcut.Action.rateFormatter.string(from: amount as NSNumber)!
            return "\(defaultDescription) (\(formattedAmount)x)"
        case let .setRate(rate):
            guard let rate else { return "Toggle Default Speed" }
            let formattedRate = Shortcut.Action.rateFormatter.string(from: rate as NSNumber)!
            return "Toggle \(formattedRate)x Speed"
        case let .skipBackward(seconds), let .skipForward(seconds):
            let formattedSeconds = Shortcut.Action.timeFormatter.string(from: seconds as NSNumber)!
            return "\(defaultDescription) (\(formattedSeconds)s)"
        default:
            return defaultDescription
        }
    }

    var defaultDescription: String {
        switch self {
        case .speedUp: "Speed Up"
        case .slowDown: "Slow Down"
        case .setRate: "Toggle Speed"
        case .showRate: "Show Current Speed"
        case .playOrPause: "Play/Pause"
        case .skipForward: "Skip Forward"
        case .skipBackward: "Skip Backward"
        case .skipToEnd: "Skip to End"
        case .toggleMute: "Toggle Mute"
        case .pip: "Toggle Picture in Picture"
        case .fullscreen: "Toggle Fullscreen"
        }
    }

    var debugDescription: String {
        switch self {
        case .speedUp: "speedUp"
        case .slowDown: "slowDown"
        case .setRate: "setRate"
        case .showRate: "showRate"
        case .playOrPause: "playOrPause"
        case .skipForward: "skipForward"
        case .skipBackward: "skipBackward"
        case .skipToEnd: "skipToEnd"
        case .toggleMute: "toggleMute"
        case .pip: "pip"
        case .fullscreen: "toggleFullscreen"
        }
    }

    var index: Int {
        switch self {
        case .speedUp: 0
        case .slowDown: 1
        case .setRate: 2
        case .showRate: 3
        case .playOrPause: 4
        case .skipForward: 5
        case .skipBackward: 6
        case .skipToEnd: 7
        case .toggleMute: 8
        case .pip: 9
        case .fullscreen: 10
        }
    }

    var dictionaryRepresentation: [String: Any] {
        var value: [String: Any] = ["action": debugDescription]

        switch self {
        case let .slowDown(amount), let .speedUp(amount):
            value["amount"] = amount
        case let .setRate(rate):
            value["rate"] = rate
        case let .skipBackward(seconds), let .skipForward(seconds):
            value["seconds"] = seconds
        default:
            break
        }

        return value
    }
}
