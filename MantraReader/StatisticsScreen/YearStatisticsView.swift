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
    
    var body: some View {
        Chart(data, id: \.period) {
            BarMark(
                x: .value("Date", $0.period, unit: .month),
                y: .value("Readings", $0.readings),
                width: 16
            )
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
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
