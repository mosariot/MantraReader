//
//  MonthStatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct MonthStatisticsView: View {
    @State var data: [Reading] = ReadingsData.last30Days
    @State private var selectedDate: Date?
    @State private var selectedMonth: Int
    @Binding var monthHeader: String
    private var currentMonth: Date { Calendar(identifier: .gregorian).dateComponents([.month], from: Date()).month! }
    private var currentYear: Date { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    
    var body: some View {
        VStack {
            HStack {
                Text("Month total: \(data.map { $0.readings }.reduce(0, +))")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            HStack {
                Text("Daily average: \(data.count != 0 ? (data.map { $0.readings }.reduce(0, +) / data.count) : 0)")
                    .foregroundColor(.secondary)
                Spacer()
            }
            Chart(data, id: \.period) {
                BarMark(
                    x: .value("Date", $0.period, unit: .day),
                    y: .value("Readings", $0.readings)
                )
                .foregroundStyle(.green.gradient)
                if let selectedDate,
                   let readings = data.first(where: { $0.period == selectedDate })?.readings {
                    RuleMark(
                        x: .value("Date", Calendar(identifier: .gregorian).date(byAdding: .hour, value: 12, to: selectedDate)!),
                        yStart: .value("Start", readings),
                        yEnd: .value("End", data.map { $0.readings }.max() ?? 0)
                    )
                    .foregroundStyle(.gray)
                    .annotation(position: .top) {
                        VStack {
                            Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted))")
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
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .onTapGesture{}
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                    if let gestureDate: Date = proxy.value(atX: x) {
                                        self.selectedDate = gestureDate.startOfDay
                                    }
                                }
                                .onEnded { value in
                                    selectedDate = nil
                                }
                        )
                }
            }
            .frame(height: 150)
            Picker("Select Month", selection: $selectedMonth) {
                Text("Last 30 days").tag(0)
                ForEach((1...currentMonth), id: \.self) {
                    Text("\(date(year: currentYear, month: $0).formatted(.dateTime.month(.wide)))").tag($0)
                }
            }
            .padding(.top, 10)
        }
        .onChange(of: selectedMonth) { newValue in
            switch selectedMonth {
                case 0: monthHeader = String(localized: "Month")
                case 1...currentMonth: monthHeader = date(year: currentYear, month: newValue).formatted(.dateTime.month(.wide))
                default: String(localized: "Month")
            }
        }
    }
}
