//
//  YearStatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct YearStatisticsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var data: [Reading]
    @State private var selectedMonth: Date?
    @Binding var selectedYear: Int
    var currentYear: Int { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    
    var body: some View {
        VStack {
            HStack {
                Text("Year total: \(data.map { $0.readings }.reduce(0, +))")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            HStack {
                Text("Monthly average: \(data.count != 0 ? (data.map { $0.readings }.reduce(0, +) / data.count) : 0)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Chart(data, id: \.period) {
                BarMark(
                    x: .value("Date", $0.period, unit: .month),
                    y: .value("Readings", $0.readings),
                    width: horizontalSizeClass == .regular ? 32 : 16
                )
                .foregroundStyle(.red.gradient)
                if let selectedMonth,
                   let readings = data.first(where: { $0.period == selectedMonth })?.readings {
                    RuleMark(
                        x: .value("Date", Calendar(identifier: .gregorian).date(byAdding: .day, value: 15, to: selectedMonth)!),
                        yStart: .value("Start", readings),
                        yEnd: .value("End", data.map { $0.readings }.max() ?? 0)
                    )
                    .foregroundStyle(.gray)
                    .annotation(position: .top) {
                        VStack {
                            Text("\(selectedMonth.formatted(.dateTime.month().year()))")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(readings)")
                                .font(.title2.bold())
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(.white.shadow(.drop(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)))
                        }
                    }
                }
            }
            .padding(.top, 10)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(horizontalSizeClass == .regular ? .abbreviated : .narrow), centered: true)
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .onTapGesture{}
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
            .frame(height: 150)
            Picker("Select Year", selection: $selectedYear) {
                Text("Last 12 months").tag(0)
                ForEach((2022...currentYear), id: \.self) {
                    Text("\(date(year: $0).formatted(.dateTime.year()))").tag($0)
                }
            }
            .padding(.top, 10)
        }
    }
}
