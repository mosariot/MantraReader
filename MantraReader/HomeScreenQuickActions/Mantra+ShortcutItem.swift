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
        if let shortcutItems = UIApplication.shared.shortcutItems?.prefix(2) {
            if !shortcutItems.map( { $0.userInfo?["MantraID"] as? String }).contains(uuid?.uuidString) {
                UIApplication.shared.shortcutItems = Array(shortcutItems)
                UIApplication.shared.shortcutItems?.insert(shortcutItem, at: 0)
            } else if shortcutItems.count == 1 {
                if shortcutItems[0].userInfo?["MantraID"] as? String == uuid?.uuidString {
                    return
                } else {
                    UIApplication.shared.shortcutItems?.insert(shortcutItem, at: 0)
                    return
                }
            } else if let secondItem = shortcutItems[1], let uuid, secondItem.userInfo?["MantraID"] as? String == uuid.uuidString {
                UIApplication.shared.shortcutItems?.swap(at: 0, 1)
                return
            }
        } else {
            UIApplication.shared.shortcutItems?.insert(shortcutItem, at: 0)
        }
    }
    
    private var shortcutItem: UIApplicationShortcutItem? {
        guard let title, !title.isEmpty, let uuid else { return nil }
        
        return UIApplicationShortcutItem(
            type: ActionType.openMantra.rawValue,
            localizedTitle: String(localized: "Recent Mantra"),
            localizedSubtitle: title,
            icon: .init(systemImageName: "book"),
            userInfo: [
                "MantraID": uuid.uuidString as NSString
            ]
        )
    }
}
