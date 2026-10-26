import SwiftUI

// MARK: - Tokens

enum GlassTheme {
    static let controlRadius: CGFloat = 10
    static let innerRadius: CGFloat = 14
    static let cardRadius: CGFloat = 20
    static let heroRadius: CGFloat = 24

    /// Follow the system accent so controls keep their normal macOS colors.
    static func accent(for scheme: ColorScheme) -> Color {
        _ = scheme
        return .accentColor
    }
}

// MARK: - Backdrop

/// Near-flat window backdrop with just enough vertical gradient to add depth.
struct WindowBackdrop: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        LinearGradient(
            colors: scheme == .dark
                ? [
                    Color(red: 0.135, green: 0.142, blue: 0.165),
                    Color(red: 0.100, green: 0.106, blue: 0.124)
                ]
                : [
                    Color(red: 0.975, green: 0.976, blue: 0.985),
                    Color(red: 0.935, green: 0.940, blue: 0.955)
                ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Surfaces

/// Standard flat card surface: bright enough to separate from the background,
/// with a hairline border and almost no shadow in dark mode.
struct SurfaceCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat = GlassTheme.cardRadius
    var elevated: Bool = true

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background {
                shape
                    .fill(
                        scheme == .dark
                            ? Color(red: 0.172, green: 0.180, blue: 0.205)
                            : Color(nsColor: .controlBackgroundColor)
                    )
                    .overlay {
                        shape.fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(scheme == .dark ? 0.045 : 0.16),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
            }
            .overlay {
                shape.strokeBorder(
                    Color.white.opacity(scheme == .dark ? 0.10 : 0.0),
                    lineWidth: 0.8
                )
            }
            .overlay {
                if scheme != .dark {
                    shape.strokeBorder(Color.primary.opacity(0.07), lineWidth: 0.8)
                }
            }
            .clipShape(shape)
            .shadow(
                color: .black.opacity(scheme == .dark ? 0.28 : 0.05),
                radius: elevated ? 10 : 0,
                x: 0,
                y: elevated ? 4 : 0
            )
    }
}

/// Frosted surface reserved for the detail hero.
struct GlassPanelModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat = GlassTheme.heroRadius
    var tint: Color = .clear

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(scheme == .dark ? 0.085 : 0.18),
                                tint.opacity(scheme == .dark ? 0.07 : 0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(scheme == .dark ? 0.18 : 0.50),
                            Color.primary.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
            }
            .clipShape(shape)
            .shadow(color: .black.opacity(scheme == .dark ? 0.20 : 0.06), radius: 12, x: 0, y: 5)
    }
}

/// Small frosted control for the sidebar sort button.
struct GlassControlModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat = GlassTheme.controlRadius

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background {
                shape.fill(.thinMaterial)
                    .overlay(shape.fill(Color.white.opacity(scheme == .dark ? 0.05 : 0.18)))
            }
            .overlay {
                shape.strokeBorder(Color.white.opacity(scheme == .dark ? 0.12 : 0.40), lineWidth: 0.8)
            }
            .clipShape(shape)
    }
}

extension View {
    func cardSurface(cornerRadius: CGFloat = GlassTheme.cardRadius, elevated: Bool = true) -> some View {
        modifier(SurfaceCardModifier(cornerRadius: cornerRadius, elevated: elevated))
    }

    func glassPanel(cornerRadius: CGFloat = GlassTheme.heroRadius, tint: Color = .clear) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius, tint: tint))
    }

    func glassControl(cornerRadius: CGFloat = GlassTheme.controlRadius) -> some View {
        modifier(GlassControlModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Small components

/// Compact monochrome accent tile used in the hero.
struct AccentGlyphTile: View {
    @Environment(\.colorScheme) private var scheme
    let systemName: String
    var size: CGFloat = 56

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
        ZStack {
            shape
                .fill(
                    LinearGradient(
                        colors: [
                            GlassTheme.accent(for: scheme).opacity(scheme == .dark ? 0.28 : 0.20),
                            GlassTheme.accent(for: scheme).opacity(scheme == .dark ? 0.12 : 0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            shape.strokeBorder(Color.white.opacity(scheme == .dark ? 0.18 : 0.45), lineWidth: 0.8)
            Image(systemName: systemName)
                .font(.system(size: size * 0.40, weight: .semibold))
                .foregroundStyle(GlassTheme.accent(for: scheme))
        }
        .frame(width: size, height: size)
    }
}

/// Lightweight ellipsis action used in card headers. No filled circle.
struct CardMenuButton: View {
    @Environment(\.colorScheme) private var scheme
    @State private var isHovering = false
    let content: () -> AnyView

    init<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = { AnyView(content()) }
    }

    var body: some View {
        Menu {
            content()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 22)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.primary.opacity(isHovering ? 0.06 : 0))
                )
                .contentShape(Rectangle())
                .onHover { isHovering = $0 }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
    }
}

/// Section divider used between rows inside a card.
struct HairlineDivider: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(scheme == .dark ? 0.08 : 0.06))
            .frame(height: 0.8)
    }
}
