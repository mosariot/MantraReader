//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI

enum ColorScheme: String, Hashable, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
}

enum RingColor: String, Hashable {
    case red
    case green
    case blue
    case dynamic
    
    var colors: [Color] {
        switch self {
        case .red: return [.progressRedStart, .progressRedEnd]
        case .green: return [.progressGreenStart, .progressGreenEnd]
        case .blue: return [.progressBlueStart, .progressBlueEnd]
        default: return [.red]
        }
    }
}

extension Color {
    static let progressRedStart = Color("progressStart")
    static let progressRedEnd = Color("progressEnd")
    static let progressBlueStart = Color("progressBlueStart")
    static let progressBlueEnd = Color("progressBlueEnd")
    static let progressGreenStart = Color("progressGreenStart")
    static let progressGreenEnd = Color("progressGreenEnd")
}

struct CornerRadiusShape: Shape {
    var radius = CGFloat.infinity
    var corners = UIRectCorner.allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

struct SettingsView: View {
    @AppStorage("sorting") private var sorting: Sorting = .title
    @AppStorage("ringColor") private var ringColor: RingColor = .red
    @AppStorage("colorScheme") private var colorScheme: ColorScheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Text("Alphabetically")
                        .tag(Sorting.title)
                    Text("By readings count")
                        .tag(Sorting.reads)
                }
                Picker("Ring color", selection: $ringColor) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: RingColor.red.colors],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(maxWidth: 200)
                        .tag(RingColor.red)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.green)
                        .frame(maxWidth: 200)
                        .tag(RingColor.green)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .frame(maxWidth: 200)
                        .tag(RingColor.blue)
                    HStack {
                        Rectangle()
                            .fill(.blue)
                            .cornerRadius(radius: 10.0, corners: [.topLeft, .bottomLeft])
                        Rectangle()
                            .fill(.green)
                        Rectangle()
                            .fill(.red)
                            .cornerRadius(radius: 10.0, corners: [.topRight, .bottomRight])
                    }
                    .frame(maxWidth: 200)
                    .tag(RingColor.dynamic)
                }
                Picker("Appearance", selection: $colorScheme) {
                    ForEach(ColorScheme.allCases) { scheme in
                        Text(scheme.rawValue.capitalized)
                            .tag(scheme)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
