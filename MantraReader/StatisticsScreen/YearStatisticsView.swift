//
//  YearStatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct YearStatisticsView: View {
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
#endif
    var data: [Reading]
    @State private var selectedMonth: Date?
    @Binding var selectedYear: Int
    let isLoadingStatistics: Bool
    private var currentYear: Int { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    private var yearTotal: Int { data.map { $0.readings }.reduce(0, +) }
    private var monthlyAverage: Int { data.count != 0 ? (data.map { $0.readings }.reduce(0, +) / data.count) : 0 }
    
    var body: some View {
        VStack {
            HStack {
#if os(iOS)
                Text("Year total:")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
#elseif os(watchOS)
                Text("Total:")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
#endif
                Text("\(yearTotal)")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -3)
                    .animation(.easeInOut(duration: 0.15), value: data)
                Spacer()
            }
            HStack {
#if os(iOS)
                Text("Monthly average:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
#elseif os(watchOS)
                Text("Average:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
#endif
                Text("\(monthlyAverage)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, -3)
                    .animation(.easeInOut(duration: 0.15), value: data)
                Spacer()
            }
            ZStack {
                Chart {
                    ForEach(data, id: \.period) {
#if os(iOS)
                        BarMark(
                            x: .value("Date", $0.period, unit: .month),
                            y: .value("Readings", $0.readings),
                            width: horizontalSizeClass == .regular || verticalSizeClass == .compact ? 32 : 16
                        )
                        .foregroundStyle(.red.gradient)
#elseif os(watchOS)
                        BarMark(
                            x: .value("Date", $0.period, unit: .month),
                            y: .value("Readings", $0.readings)
                        )
                        .foregroundStyle(.red.gradient)
#endif
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: data)
                .padding(.top, 10)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisTick()
#if os(iOS)
                        AxisValueLabel(format: .dateTime.month(horizontalSizeClass == .regular || verticalSizeClass == .compact ? .abbreviated : .narrow), centered: true)
#elseif os(watchOS)
                        AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
#endif
                    }
                }
#if os(iOS)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .onTapGesture {}
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                        if let gestureMonth: Date = proxy.value(atX: x) {
                                            selectedMonth = gestureMonth.startOfMonth
                                        }
                                    }
                                    .onEnded { value in
                                        selectedMonth = nil
                                    }
                            )
                    }
                }
                .chartOverlay { proxy in
                    ZStack(alignment: .topLeading) {
                        GeometryReader { geo in
                            if let selectedMonth,
                               let readings = data.first(where: { $0.period == selectedMonth })?.readings {
                                let startPositionX1 = proxy.position(forX: Calendar(identifier: .gregorian).date(byAdding: .day, value: 15, to: selectedMonth) ?? Date()) ?? 0
                                let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                                let lineHeight = geo[proxy.plotAreaFrame].maxY
                                let boxWidth: CGFloat = 110
                                let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
                                Rectangle()
                                    .fill(.gray.opacity(0.5))
                                    .frame(width: 3, height: lineHeight)
                                    .position(x: lineX, y: lineHeight / 2)
                                VStack {
                                    Text("\(selectedMonth.formatted(.dateTime.month().year()))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(readings)")
                                        .font(.title2.bold())
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 4)
                                .frame(width: boxWidth)
                                .background {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(.white.shadow(.drop(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)))
                                }
                                .offset(x: boxOffset, y: -25)
                            }
                        }
                    }
                }
                .frame(height: 150)
#elseif os(watchOS)
                .frame(height: 70)
#endif
                if isLoadingStatistics {
                    ProgressView()
                        .frame(height: 150)
                }
            }
            HStack {
                Button {
                    if selectedYear == 0 {
                        selectedYear = currentYear - 1
                    } else {
                        selectedYear -= 1
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .tint(.red.opacity(0.8))
                .disabled(selectedYear == 2022 || (selectedYear == 0 && currentYear == 2022))
#if os(watchOS)
                .controlSize(.mini)
                .scaleEffect(0.5)
#endif
                Spacer()
#if os(iOS)
                    .frame(minWidth: 0, maxWidth: !(horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 60 : nil)
#endif
                Picker("", selection: $selectedYear) {
#if os(iOS)
                    Text("Last 12 Months").tag(0)
#elseif os(watchOS)
                    Text("12 Months").tag(0)
#endif
                    ForEach((2022...currentYear).reversed(), id: \.self) {
                        Text("\(date(year: $0).formatted(.dateTime.year()))").tag($0)
                    }
                }
                .layoutPriority(1)
                .labelsHidden()
                Spacer()
#if os(iOS)
                    .frame(minWidth: 0, maxWidth: !(horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 60 : nil)
#endif
                Button {
                    if selectedYear == 0 {
                        selectedYear = currentYear
                    } else {
                        selectedYear += 1
                    }
                } label: {
                    Image(systemName: "chevron.forward")

                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .tint(.red.opacity(0.8))
                .disabled(selectedYear == currentYear)
#if os(watchOS)
                .controlSize(.mini)
                .scaleEffect(0.5)
#endif
            }
#if os(iOS)
            .padding(.top, 10)
#elseif os(watchOS)
            .padding(0)
#endif
            .disabled(isLoadingStatistics)
        }
    }
}
