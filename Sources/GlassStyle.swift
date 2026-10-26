import SwiftUI

// MARK: - Liquid Glass Theme

enum GlassTheme {
    static let cornerRadius: CGFloat = 24

    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.47, green: 0.72, blue: 1.0)
            : Color(red: 0.26, green: 0.49, blue: 0.98)
    }

    static func secondaryAccent(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.72, green: 0.52, blue: 1.0)
            : Color(red: 0.55, green: 0.36, blue: 0.98)
    }

    static func mint(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.36, green: 0.88, blue: 0.78)
            : Color(red: 0.16, green: 0.72, blue: 0.64)
    }
}

// MARK: - Background

/// Soft, diffuse backdrop that gives glass panels something colorful to refract.
struct LiquidGlassBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)

            LinearGradient(
                colors: scheme == .dark
                    ? [
                        Color(red: 0.05, green: 0.06, blue: 0.10),
                        Color(red: 0.08, green: 0.10, blue: 0.16),
                        Color(red: 0.06, green: 0.07, blue: 0.12)
                    ]
                    : [
                        Color(red: 0.97, green: 0.975, blue: 1.0),
                        Color(red: 0.92, green: 0.945, blue: 1.0),
                        Color(red: 0.965, green: 0.95, blue: 0.995)
                    ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(GlassTheme.accent(for: scheme).opacity(scheme == .dark ? 0.32 : 0.22))
                        .frame(width: proxy.size.width * 1.0)
                        .blur(radius: 150)
                        .offset(x: -proxy.size.width * 0.28, y: -proxy.size.height * 0.30)

                    Circle()
                        .fill(GlassTheme.secondaryAccent(for: scheme).opacity(scheme == .dark ? 0.24 : 0.16))
                        .frame(width: proxy.size.width * 0.9)
                        .blur(radius: 160)
                        .offset(x: proxy.size.width * 0.32, y: proxy.size.height * 0.32)

                    Circle()
                        .fill(GlassTheme.mint(for: scheme).opacity(scheme == .dark ? 0.16 : 0.12))
                        .frame(width: proxy.size.width * 0.7)
                        .blur(radius: 130)
                        .offset(x: proxy.size.width * 0.10, y: -proxy.size.height * 0.05)
                }
            }
        }
        .ignoresSafeArea()
    }
}

/// Slightly stronger sidebar material with a vertical sheen.
struct GlassSidebarBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            LinearGradient(
                colors: [
                    Color.white.opacity(scheme == .dark ? 0.07 : 0.30),
                    Color.white.opacity(scheme == .dark ? 0.01 : 0.08),
                    GlassTheme.accent(for: scheme).opacity(scheme == .dark ? 0.06 : 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass Card

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat = GlassTheme.cornerRadius
    var tint: Color = .clear
    var elevated: Bool = true
    var tintStrength: Double = 1.0

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
                                Color.white.opacity(scheme == .dark ? 0.12 : 0.46),
                                Color.white.opacity(scheme == .dark ? 0.03 : 0.16),
                                tint.opacity((scheme == .dark ? 0.22 : 0.12) * tintStrength)
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
                            Color.white.opacity(scheme == .dark ? 0.38 : 0.90),
                            Color.white.opacity(scheme == .dark ? 0.06 : 0.28),
                            Color.black.opacity(scheme == .dark ? 0.28 : 0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
            .overlay(alignment: .topLeading) {
                Capsule()
                    .fill(Color.white.opacity(scheme == .dark ? 0.24 : 0.65))
                    .frame(width: 120, height: 1.5)
                    .blur(radius: 0.8)
                    .padding(.top, 1)
                    .padding(.leading, max(20, cornerRadius))
                    .opacity(0.85)
            }
            .clipShape(shape)
            .compositingGroup()
            .shadow(
                color: .black.opacity(scheme == .dark ? 0.42 : 0.10),
                radius: elevated ? 26 : 14,
                x: 0,
                y: elevated ? 14 : 7
            )
            .shadow(
                color: .black.opacity(scheme == .dark ? 0.20 : 0.05),
                radius: 2,
                x: 0,
                y: 1
            )
    }
}

extension View {
    func glassCard(
        cornerRadius: CGFloat = GlassTheme.cornerRadius,
        tint: Color = .clear,
        elevated: Bool = true,
        tintStrength: Double = 1.0
    ) -> some View {
        modifier(
            GlassCardModifier(
                cornerRadius: cornerRadius,
                tint: tint,
                elevated: elevated,
                tintStrength: tintStrength
            )
        )
    }

    /// Frosted chrome for small controls (menus, toggles, badges).
    func glassControl(cornerRadius: CGFloat = 10) -> some View {
        modifier(GlassControlModifier(cornerRadius: cornerRadius))
    }
}

struct GlassControlModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var cornerRadius: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background {
                shape.fill(.thinMaterial)
                    .overlay(
                        shape.fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(scheme == .dark ? 0.14 : 0.45),
                                    Color.white.opacity(scheme == .dark ? 0.02 : 0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    )
            }
            .overlay {
                shape.strokeBorder(Color.white.opacity(scheme == .dark ? 0.18 : 0.55), lineWidth: 0.8)
            }
            .clipShape(shape)
    }
}

// MARK: - Glass Logo Tile

struct GlassIconTile: View {
    @Environment(\.colorScheme) private var scheme
    let systemName: String
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            GlassTheme.accent(for: scheme).opacity(scheme == .dark ? 0.55 : 0.35),
                            GlassTheme.secondaryAccent(for: scheme).opacity(scheme == .dark ? 0.35 : 0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.35)
                )

            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(scheme == .dark ? 0.45 : 0.90),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white.opacity(scheme == .dark ? 0.95 : 0.98))
                .shadow(color: GlassTheme.accent(for: scheme).opacity(0.5), radius: 6, y: 2)
        }
        .frame(width: size, height: size)
        .shadow(color: GlassTheme.accent(for: scheme).opacity(scheme == .dark ? 0.35 : 0.20), radius: 14, y: 6)
    }
}
