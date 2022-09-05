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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
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
                Text("Year total:")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Text("\(yearTotal)")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -3)
                    .animation(.easeInOut(duration: 0.15), value: data)
                Spacer()
            }
            HStack {
                Text("Monthly average:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
                        BarMark(
                            x: .value("Date", $0.period, unit: .month),
                            y: .value("Readings", $0.readings),
                            width: horizontalSizeClass == .regular || verticalSizeClass == .compact ? 32 : 16
                        )
                        .foregroundStyle(.red.gradient)
                    }
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
                                    .fill(.white.shadow(.drop(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)))
                            }
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: data)
                .padding(.top, 10)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(horizontalSizeClass == .regular || verticalSizeClass == .compact ? .abbreviated : .narrow), centered: true)
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
                if isLoadingStatistics  {
                    ProgressView()
                        .frame(height: 150)
                }
            }
            HStack {
                Button {
                    if selectedYear == 0 && currentYear != 2022 {
                        selectedYear = currentYear - 1
                    } else {
                        selectedYear - 1
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .tint(.gray)
                .shadow(color: black.opacity(0.5), radius: 2, x: 2, y: 2)
                .disabled(selectedYear == 2022)
                Spacer()
                Picker("", selection: $selectedYear) {
                    Text("Last 12 Months").tag(0)
                    ForEach((2022...currentYear).reversed(), id: \.self) {
                        Text("\(date(year: $0).formatted(.dateTime.year()))").tag($0)
                    }
                }
                Spacer()
                Button {
                    if selectedYear == 0 {
                        selectedYear = currentYear
                    } else {
                        selectedYear + 1
                    }
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .tint(.gray)
                .shadow(color: black.opacity(0.5), radius: 2, x: 2, y: 2)
                .disabled(selectedYear == currentYear)
            }
            .padding(.top, 10)
        }
    }
}
