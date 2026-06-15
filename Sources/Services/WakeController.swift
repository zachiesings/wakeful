import Foundation
import IOKit.pwr_mgt

/// Keeps the Mac awake using an IOKit power-management assertion. This is the
/// App Store-approved API — it needs **no** special entitlement, no
/// Accessibility, and no Input Monitoring.
@MainActor
final class WakeController: ObservableObject {
    @Published private(set) var isActive = false
    private var assertionID: IOPMAssertionID = 0

    /// - Parameter displayOn: when true the display is also kept on
    ///   (`NoDisplaySleep`); otherwise only the system is kept awake
    ///   (`NoIdleSleep`), letting the screen dim.
    func start(displayOn: Bool) {
        stop()
        let type = (displayOn ? kIOPMAssertionTypeNoDisplaySleep
                              : kIOPMAssertionTypeNoIdleSleep) as CFString
        var id = IOPMAssertionID(0)
        let reason = "Wakeful is keeping your Mac awake" as CFString
        let result = IOPMAssertionCreateWithName(type,
                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                 reason, &id)
        if result == kIOReturnSuccess {
            assertionID = id
            isActive = true
        }
    }

    func stop() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        isActive = false
    }
}
