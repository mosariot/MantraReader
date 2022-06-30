//
//  OrientationInfo.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI

#if os(iOS)
final class OrientationInfo: ObservableObject {
    enum Orientation {
        case portrait
        case landscape
    }
    
    @Published var orientation: Orientation
    
    private var observer: NSObjectProtocol?
    
    init() {
        if UIDevice.current.orientation.isLandscape {
            self.orientation = .landscape
        } else {
            self.orientation = .portrait
        }
        
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: nil
        ) { [unowned self] note in
            guard let device = note.object as? UIDevice else { return }
            if device.orientation.isPortrait {
                self.orientation = .portrait
            } else if device.orientation.isLandscape {
                self.orientation = .landscape
            }
        }
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
#endif
