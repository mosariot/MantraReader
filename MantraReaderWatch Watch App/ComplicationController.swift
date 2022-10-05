//
//  ComplicationController.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 05.10.2022.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func complicationDescriptors() async -> [CLKComplicationDescriptor] {
        [CLKComplicationDescriptor(
            identifier: "com.mosariot.MantraReader",
            displayName: "Mantra Reader",
            supportedFamilies: .allCases)]
    }
    
    func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? { nil }
}
