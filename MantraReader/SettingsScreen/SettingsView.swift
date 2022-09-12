//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI

enum MantraColorScheme: String, Hashable, CaseIterable, Identifiable {
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
    static let progressRedStart = Color(#colorLiteral(red: 0.882, green: 0.000, blue: 0.086, alpha: 1))
    static let progressRedEnd = Color(#colorLiteral(red: 1.000, green: 0.196, blue: 0.533, alpha: 1))
    static let progressGreenStart = Color(#colorLiteral(red: 0.216, green: 0.863, blue: 0.000, alpha: 1))
    static let progressGreenEnd = Color(#colorLiteral(red: 0.714, green: 1.000, blue: 0.000, alpha: 1))
    static let progressBlueStart = Color(#colorLiteral(red: 0.000, green: 0.733, blue: 0.890, alpha: 1))
    static let progressBlueEnd = Color(#colorLiteral(red: 0.000, green: 0.984, blue: 0.816, alpha: 1))
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
    @Environment(\.dismiss) var dismiss
    @AppStorage("sorting") private var sorting: Sorting = .title
    @AppStorage("ringColor") private var ringColor: RingColor = .red
    @AppStorage("colorScheme") private var colorScheme: MantraColorScheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Text("Alphabetically")
                        .tag(Sorting.title)
                    Text("By readings count")
                        .tag(Sorting.reads)
                }
                Picker("Appearance", selection: $colorScheme) {
                    ForEach(MantraColorScheme.allCases) { scheme in
                        Text(scheme.rawValue.capitalized)
                            .tag(scheme)
                    }
                }
                Picker("Ring color", selection: $ringColor) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: RingColor.red.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 25)
                        .tag(RingColor.red)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: RingColor.green.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 25)
                        .tag(RingColor.green)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: RingColor.blue.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 25)
                        .tag(RingColor.blue)
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.blue.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(radius: 10.0, corners: [.topLeft, .bottomLeft])
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.green.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.red.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(radius: 10.0, corners: [.topRight, .bottomRight])
                    }
                    .frame(height: 25)
                    .tag(RingColor.dynamic)
                }
                .pickerStyle(.inline)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .symbolVariant(.circle.fill)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
