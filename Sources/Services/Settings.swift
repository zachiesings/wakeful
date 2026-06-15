import SwiftUI

/// Lightweight, observable user preferences backed by `UserDefaults`.
final class Settings: ObservableObject {
    static let shared = Settings()
    private let d = UserDefaults.standard

    @Published var keepDisplayOn: Bool {
        didSet { d.set(keepDisplayOn, forKey: "wakeful.keepDisplayOn") }
    }
    @Published var themeID: String {
        didSet { d.set(themeID, forKey: "wakeful.theme") }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            d.set(launchAtLogin, forKey: "wakeful.launchAtLogin")
            LoginItem.setEnabled(launchAtLogin)
        }
    }

    var theme: AppTheme { AppTheme(rawValue: themeID) ?? .aurora }

    private init() {
        keepDisplayOn = d.object(forKey: "wakeful.keepDisplayOn") as? Bool ?? true
        themeID = d.string(forKey: "wakeful.theme") ?? AppTheme.aurora.rawValue
        launchAtLogin = LoginItem.isEnabled
    }
}
