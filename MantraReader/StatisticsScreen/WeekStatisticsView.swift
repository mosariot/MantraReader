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
    
    var body: some View {
        Chart(data, id: \.period) {
            BarMark(
                x: .value("Date", $0.period, unit: .weekday),
                y: .value("Readings", $0.readings),
                width: 30
            )
            if let selectedDate,
               let readings = data
                .first(where: { $0.period == Calendar.current.startOfDay(for: selectedDate) })?.readings {
                RuleMark(x: .value("Date", selectedDate))
                    .annotation(position: .trailing, alignment: .top) {
                        Text("\(readings)")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .background {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.background)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.quaternary.opacity(0.7))
                                }
                                .padding(.horizontal, -8)
                                .padding(.vertical, -4)
                            }
                            .padding(.bottom, 4)
                    }
            }
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
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let gestureDate: Date = proxy.value(atX: x) {
                                    let startOfDay = Calendar.current.startOfDay(for: gestureDate)
                                    self.selectedDate = Calendar.current.date(byAdding: .hour, value: 12, to: startOfDay)
                                }
                            }
                            .onEnded { value in
                                self.selectedDate = nil
                            }
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
