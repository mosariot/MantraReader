//
//  FeedbackView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 14.09.2022.
//

import SwiftUI
import MessageUI

struct FeedbackView: UIViewControllerRepresentable {
    var to: String
    var subject: String
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) { }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        if MFMailComposeViewController.canSendMail() {
            let view = MFMailComposeViewController()
            view.mailComposeDelegate = context.coordinator
            view.setToRecipients([to])
            view.setSubject(subject)
            return view
        } else {
            return MFMailComposeViewController()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: FeedbackView
        
        init(_ parent: FeedbackView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
