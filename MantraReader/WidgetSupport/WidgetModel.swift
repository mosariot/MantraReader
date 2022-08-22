//
//  WidgetModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.12.2020.
//

import Foundation

struct WidgetModel: Identifiable, Codable {
    var id = UUID()
    let mantras: [WidgetMantra]
    
    struct WidgetMantra: Identifiable, Codable, Hashable {
        let id: UUID
        let title: String
        let reads: Int32
        let goal: Int32
        let image: Data?
    }
}
