//
//  PreloadedMantra.swift
//  MantraReader
//
//  Created by Александр Воробьев on 02.08.2022.
//

import Foundation

struct PreloadedMantra: Identifiable, Hashable {
    let id = UUID()
    var title: String = ""
    var imageString: String = ""
    var isSelected: Bool = false
}
