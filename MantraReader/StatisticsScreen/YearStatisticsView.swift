//
//  YearStatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI
import Charts

struct YearStatisticsView: View {
    @State var data: [Reading] = ReadingsData.last12Months
    @State private var selectedMonth: Date?
    private var calendar = Calendar.current
    
    var body: some View {
        VStack {
            HStack {
                Text("Year total: \(data.map { $0.readings }.reduce(0, +))")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            Chart(data, id: \.period) {
                BarMark(
                    x: .value("Date", $0.period, unit: .month),
                    y: .value("Readings", $0.readings),
                    width: 16
                )
                if let selectedMonth,
                   let readings = data.first(where: { $0.period == selectedMonth })?.readings {
                    RuleMark(
                        x: .value("Date", calendar.date(byAdding: .day, value: 15, to: selectedMonth) ?? Date()),
                        yStart: .value("Start", readings),
                        yEnd: .value("End", data.map { $0.readings }.max() ?? 0)
                    )
                    .foregroundStyle(Color.secondary)
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
            .padding(.top, 20)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
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
    }
}

struct YearStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        YearStatisticsView()
            .frame(height: 200)
    }
}
