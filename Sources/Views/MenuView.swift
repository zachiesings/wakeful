import SwiftUI

struct MenuView: View {
    @EnvironmentObject var model: AppModel
    @State private var showPaywall = false
    @State private var showSettings = false

    private var theme: AppTheme { model.settings.theme }
    private var active: Bool { model.wake.isActive }

    var body: some View {
        VStack(spacing: 0) {
            if showSettings {
                SettingsView(onBack: { showSettings = false }, showPaywall: { showSettings = false; showPaywall = true })
                    .environmentObject(model)
            } else {
                main
            }
        }
        .frame(width: 300)
        .sheet(isPresented: $showPaywall) {
            PaywallView().environmentObject(model)
        }
    }

    private var main: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Wakeful").font(.headline)
                Spacer()
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape").foregroundStyle(.secondary)
                }.buttonStyle(.plain)
            }

            // Status dial
            Button(action: { model.toggle() }) {
                VStack(spacing: 6) {
                    Image(systemName: active ? "cup.and.saucer.fill" : "moon.zzz.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(active ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
                    Text(active ? (model.remaining != nil ? model.remainingText : "Awake") : "Asleep")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(active ? .white : .secondary)
                    Text(active ? "Click to let it sleep" : "Click to keep awake")
                        .font(.caption2)
                        .foregroundStyle(active ? .white.opacity(0.85) : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(active
                              ? AnyShapeStyle(LinearGradient(colors: theme.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                              : AnyShapeStyle(Color.primary.opacity(0.06)))
                )
            }
            .buttonStyle(.plain)

            // Timer presets (Pro)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Text("Timed session").font(.caption).foregroundStyle(.secondary)
                    if !model.isPro {
                        Image(systemName: "crown.fill").font(.system(size: 9)).foregroundStyle(theme.accent)
                    }
                }
                HStack(spacing: 6) {
                    presetChip("15m", 15 * 60)
                    presetChip("30m", 30 * 60)
                    presetChip("1h", 60 * 60)
                    presetChip("2h", 120 * 60)
                }
            }

            Divider()

            // Footer actions
            if !model.isPro {
                Button(action: { showPaywall = true }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Unlock Wakeful Pro").bold()
                        Spacer()
                        if !model.entitlements.priceText.isEmpty {
                            Text(model.entitlements.priceText).font(.caption).opacity(0.9)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9).padding(.horizontal, 12)
                    .background(LinearGradient(colors: theme.gradient, startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }.buttonStyle(.plain)
            }

            HStack {
                Button("Settings") { showSettings = true }.buttonStyle(.link)
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }.buttonStyle(.link)
            }
            .font(.caption)
        }
        .padding(16)
    }

    private func presetChip(_ label: String, _ seconds: TimeInterval) -> some View {
        Button {
            if model.isPro { model.startTimed(seconds) } else { showPaywall = true }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }.buttonStyle(.plain)
    }
}
