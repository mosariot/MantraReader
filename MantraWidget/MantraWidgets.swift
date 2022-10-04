//
//  MantraWidgets.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 16.08.2022.
//

import WidgetKit
import SwiftUI

@main
struct MantraWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
#if os(iOS)
        IntentWidget()
        StaticWidget()
#elseif os(watchOS)
        StaticWidget()
        IntentWidget()
#endif
    }
}
