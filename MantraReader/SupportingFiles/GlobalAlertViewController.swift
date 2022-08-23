//
//  GlobalAlertViewController.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 23.08.2022.
//

import UIKit

final class GlobalAlertController: UIAlertController {
    var globalPresentationWindow: UIWindow?
    
    func presentGlobally(animated: Bool, completion: (() -> Void)?) {
        globalPresentationWindow = UIWindow(frame: UIScreen.main.bounds)
        
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            globalPresentationWindow?.windowScene = currentWindowScene
        }
        
        globalPresentationWindow?.rootViewController = UIViewController()
        globalPresentationWindow?.windowLevel = UIWindow.Level.alert + 1
        globalPresentationWindow?.backgroundColor = .clear
        globalPresentationWindow?.makeKeyAndVisible()
        globalPresentationWindow?.rootViewController?.present(self, animated: animated, completion: completion)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        globalPresentationWindow?.isHidden = true
        globalPresentationWindow = nil
    }
}
