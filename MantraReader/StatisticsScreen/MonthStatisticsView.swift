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
    
    var body: some View {
        Chart(data, id: \.period) {
            BarMark(
                x: .value("Date", $0.period, unit: .day),
                y: .value("Readings", $0.readings)
            )
        }
    }
}

struct MonthStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        MonthStatisticsView()
            .frame(height: 200)
    }
}
