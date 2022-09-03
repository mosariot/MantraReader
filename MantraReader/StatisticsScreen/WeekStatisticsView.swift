//
//  WeekStatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct WeekStatisticsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var data: [Reading]?
    @State private var selectedDate: Date?
    @Binding var selectedWeek: Int
    private var currentWeek: Int { Calendar(identifier: .gregorian).dateComponents([.weekOfYear], from: Date()).weekOfYear! }
    private var currentYear: Int { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    private var weekTotal: String {
        guard let data else { return "-" }
        return "\(data.map { $0.readings }.reduce(0, +))"
    }
    private var dailyAverage: String {
        guard let data else { return "-" }
        return "\(data.count != 0 ? (data.map { $0.readings }.reduce(0, +) / data.count) : 0)"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Week Total: \(weekTotal)")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            HStack {
                Text("Daily average: \(dailyAverage)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            if let data {
                Chart {
                    ForEach(data, id: \.period) {
                        BarMark(
                            x: .value("Date", $0.period, unit: .weekday),
                            y: .value("Readings", $0.readings),
                            width: 30
                        )
                        .foregroundStyle(.blue.gradient)
                    }
                    if let selectedDate,
                       let readings = data.first(where: { $0.period == selectedDate })?.readings {
                        RuleMark(
                            x: .value("Date", Calendar(identifier: .gregorian).date(byAdding: .hour, value: 12, to: selectedDate) ?? Date()),
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
                                    .fill(.white.shadow(.drop(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)))
                            }
                        }
                    }
                }
                .animation(.easeInOut, value: data)
                .padding(.top, 10)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday(horizontalSizeClass == .regular ? .wide : .abbreviated), centered: true)
                    }
                }
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
                .frame(height: 150)
            } else {
                ProgressView()
                    .frame(height: 150)
            }
            Picker("Select Week", selection: $selectedWeek) {
                Text("Last 7 Days").tag(0)
                ForEach((2...currentWeek).reversed(), id: \.self) {
                    Text("\(startOfWeek($0).formatted(.dateTime.day().month(.abbreviated))) - \(endOfWeek($0).formatted(.dateTime.day().month(.abbreviated)))").tag($0)
                }
            }
            .padding(.top, 10)
        }
    }
    
    private func startOfWeek(_ week: Int) -> Date {
        date(year: currentYear, weekDay: 2, weekOfYear: week)
    }
    
    private func endOfWeek(_ week: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: 6, to: startOfWeek(week))!
    }
}
