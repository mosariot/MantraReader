//
//  ComplicationController.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 05.10.2022.
//

import ClockKit
class ComplicationController: NSObject, CLKComplicationDataSource {
  func complicationDescriptors() async -> [CLKComplicationDescriptor] {
    return [
      .init(
        identifier: "com.mosariot.MantraReader",
        displayName: "Mantra Reader",
        supportedFamilies: [
          .circularSmall, .extraLarge, .graphicBezel, .graphicCircular, .graphicCorner,
          .modularSmall, .utilitarianLarge, .utilitarianSmall, .utilitarianSmallFlat
        ]
      )
    ]
  }

  func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? { nil }
}
