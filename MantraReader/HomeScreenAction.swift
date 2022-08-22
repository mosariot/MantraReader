//
//  HomeScreenAction.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.08.2022.
//

#if os(iOS)
import UIKit

enum ActionType: String {
    case newMantra = "NewMantra"
    case showStatistics = "ShowStatistics"
    case openMantra = "OpenMantra"
}

enum Action: Equatable {
    case newMantra
    case showStatistics
    case openMantra(id: String)
    
    init?(shortcutItem: UIApplicationShortcutItem) {
        guard let type = ActionType(rawValue: shortcutItem.type) else { return nil }
        switch type {
        case .newMantra:
            self = .newMantra
        case .showStatistics:
            self = .showStatistics
        case .openMantra:
            if let id = shortcutItem.userInfo?["MantraID"] as? String {
                self = .openMantra(id: id)
            } else {
                return nil
            }
        }
    }
}

class ActionService: ObservableObject {
    static let shared = ActionService()
    @Published var action: Action?
}
#endif
