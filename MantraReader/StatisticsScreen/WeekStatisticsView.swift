//
//  WeekStatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct WeekStatisticsView: View {
    @State var data: [Reading] = ReadingsData.last7Days
    @State private var selectedDate: Date?
    private var calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("Week total: \(data.map { $0.readings }.reduce(0, +))")
                .font(.title3.bold())
            Chart(data, id: \.period) {
                BarMark(
                    x: .value("Date", $0.period, unit: .weekday),
                    y: .value("Readings", $0.readings),
                    width: 30
                )
                if let selectedDate,
                    let readings = data.first(where: { $0.period == selectedDate })?.readings {
                    RuleMark(
                        x: .value("Date", calendar.date(byAdding: .hour, value: 12, to: selectedDate)),
                        yStart: .value("Start", readings),
                        yEnd: .value("End", data.map { $0.readings }.max())
                    )
                    .foregroundColor(.secondary)
                    .annotation(position: .top) {
                        VStack {
                            Text("\(selectedDate.period.formatted(date: .abbreviated, time: .shortened))")
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
                                .fill(.white.shadow(.drop(radius: 2)))
                        }
                    }
                }
            }
            .padding(.top, 30)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        LongPressGesture().sequenced(before:
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                    if let gestureDate: Date = proxy.value(atX: x) {
                                        self.selectedDate = calendar.startOfDay(for: gestureDate)
                                    }
                                }
                                .onEnded { value in
                                    self.selectedDate = nil
                                }
                        )
                    )
            }
        }
    }
}

struct WeekStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        WeekStatisticsView()
            .frame(height: 200)
    }
}
