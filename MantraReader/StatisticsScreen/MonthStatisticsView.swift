//
//  MonthStatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct MonthStatisticsView: View {
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
#endif
    var data: [Reading]
    @State private var selectedDate: Date?
    @Binding var selectedMonth: Int
    let isLoadingStatistics: Bool
    private var currentMonth: Int { Calendar(identifier: .gregorian).dateComponents([.month], from: Date()).month! }
    private var currentYear: Int { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    private var monthTotal: Int { data.map { $0.readings }.reduce(0, +) }
    private var dailyAverage: Int { data.count != 0 ? (data.map { $0.readings }.reduce(0, +) / data.count) : 0 }
    
    var body: some View {
        VStack {
            HStack {
#if os(iOS)
                Text("Month total:")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
#elseif os(watchOS)
                Text("Total:")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
#endif
                Text("\(monthTotal)")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -3)
                    .animation(.easeInOut(duration: 0.15), value: data)
                Spacer()
            }
            HStack {
#if os(iOS)
                Text("Daily average:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
#elseif os(watchOS)
                Text("Average:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
#endif
                Text("\(dailyAverage)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, -3)
                    .animation(.easeInOut(duration: 0.15), value: data)
                Spacer()
            }
            ZStack {
                Chart {
                    ForEach(data, id: \.period) {
                        BarMark(
                            x: .value("Date", $0.period, unit: .day),
                            y: .value("Readings", $0.readings)
                        )
                        .foregroundStyle(.green.gradient)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: data)
                .padding(.top, 10)
#if os(watchOS)
                .chartXAxis {
                    AxisMarks() { _ in
                        AxisTick()
                        AxisValueLabel()
                    }
                }
#endif
#if os(iOS)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .onTapGesture {}
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                        if let gestureDate: Date = proxy.value(atX: x) {
                                            selectedDate = gestureDate.startOfDay
                                        }
                                    }
                                    .onEnded { value in
                                        selectedDate = nil
                                    }
                            )
                    }
                }
                .chartOverlay { proxy in
                    ZStack(alignment: .topLeading) {
                        GeometryReader { geo in
                            if let selectedDate,
                               let readings = data.first(where: { $0.period == selectedDate })?.readings {
                                let startPositionX1 = proxy.position(forX: Calendar(identifier: .gregorian)
                                    .date(byAdding: .hour, value: 12, to: selectedDate) ?? Date()) ?? 0
                                let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                                let lineHeight = geo[proxy.plotAreaFrame].maxY
                                let boxWidth: CGFloat = 110
                                let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
                                Rectangle()
                                    .fill(.gray.opacity(0.5))
                                    .frame(width: 3, height: lineHeight)
                                    .position(x: lineX, y: lineHeight / 2)
                                VStack {
                                    Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted))")
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
                .frame(height: 90)
#endif
                if isLoadingStatistics {
                    ProgressView()
                        .frame(height: 150)
                }
            }
#if os(iOS)
            HStack {
                Button {
                    if selectedMonth == 0 {
                        if currentMonth == 1 {
                            selectedMonth = 12
                        } else {
                            selectedMonth = currentMonth - 1
                        }
                    } else if selectedMonth == 1 {
                        selectedMonth = 12
                    } else {
                        selectedMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .tint(.green.opacity(0.8))
                .disabled(selectedMonth == currentMonth + 1)
                Spacer()
                    .frame(minWidth: 0, maxWidth: !(horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 60 : nil)
                Picker("", selection: $selectedMonth) {
                    Text("Last 30 Days").tag(0)
                    ForEach((1...currentMonth).reversed(), id: \.self) {
                        Text("\(date(month: $0).formatted(.dateTime.month(.wide)))").tag($0)
                    }
                    if currentMonth != 12 {
                        ForEach(((currentMonth+1)...12).reversed(), id: \.self) {
                            Text("\(date(year: currentYear-1, month: $0).formatted(.dateTime.month(.wide).year()))").tag($0)
                        }
                    }
                }
                .layoutPriority(1)
                .labelsHidden()
                Spacer()
                    .frame(minWidth: 0, maxWidth: !(horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 60 : nil)
                Button {
                    if selectedMonth == 0 {
                        selectedMonth = currentMonth
                    } else if selectedMonth == 12 {
                        selectedMonth = 1
                    } else {
                        selectedMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .tint(.green.opacity(0.8))
                .disabled(selectedMonth == currentMonth)
            }
            .padding(.top, 10)
#endif
        }
    }
}
