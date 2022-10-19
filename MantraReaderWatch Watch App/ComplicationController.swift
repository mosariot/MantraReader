//
//  ComplicationController.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 05.10.2022.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func complicationDescriptors() async -> [CLKComplicationDescriptor] { [] }
    func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? { nil }
}
