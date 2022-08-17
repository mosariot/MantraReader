//
//  Widgets.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.08.2022.
//

import WidgetKit
import SwiftUI

@main
struct MantraWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        IntentWidget()
        StaticWidget()
    }
}
