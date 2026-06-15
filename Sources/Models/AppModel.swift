import SwiftUI
import Combine

@MainActor
final class AppModel: ObservableObject {
    let wake = WakeController()
    let entitlements = Entitlements()
    let settings = Settings.shared

    /// Remaining seconds for a timed session, or nil for an indefinite session.
    @Published var remaining: TimeInterval?

    private var bag = Set<AnyCancellable>()
    private var timer: Timer?

    init() {
        // Re-broadcast nested ObservableObject changes so SwiftUI views update.
        wake.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)
        entitlements.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)
        settings.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)
    }

    var isPro: Bool { entitlements.isPro }

    func toggle() {
        if wake.isActive { stop() } else { startIndefinite() }
    }

    func startIndefinite() {
        stopTimer()
        remaining = nil
        wake.start(displayOn: settings.keepDisplayOn)
    }

    /// Pro-only: keep awake for a fixed duration, then auto-release.
    func startTimed(_ seconds: TimeInterval) {
        stopTimer()
        wake.start(displayOn: settings.keepDisplayOn)
        remaining = seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, var r = self.remaining else { return }
                r -= 1
                if r <= 0 { self.stop() } else { self.remaining = r }
            }
        }
    }

    func stop() {
        stopTimer()
        remaining = nil
        wake.stop()
    }

    var remainingText: String {
        guard let r = remaining else { return "" }
        let total = Int(r)
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
