//
//  IntentWidgetEntry.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import WidgetKit

struct IntentWidgetEntry: TimelineEntry {
    let date: Date
    let selectedMantra: WidgetModel.WidgetMantra?
    let configuration: SelectMantraIntent
}
