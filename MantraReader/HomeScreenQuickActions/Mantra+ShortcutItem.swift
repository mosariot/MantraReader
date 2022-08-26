//
//  Mantra+ShortcutItem.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 22.08.2022.
//

import UIKit

extension Mantra {
    func insertShortcutItem() {
        guard let shortcutItem else { return }
        UIApplication.shared.shortcutItems?.insert(shortcutItem, at: 0)
    }
    
    private var shortcutItem: UIApplicationShortcutItem? {
        guard let title, !title.isEmpty, let uuid else { return nil }
        
        return UIApplicationShortcutItem(
            type: ActionType.openMantra.rawValue,
            localizedTitle: String(localized: "Open Mantra"),
            localizedSubtitle: title,
            icon: .init(systemImageName: "book"),
            userInfo: [
                "MantraID": uuid.uuidString as NSString
            ]
        )
    }
}
