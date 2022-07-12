//
//  UpdatingAlertView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 12.07.2022.
//

import UIKit
import SwiftUI

struct UpdatingAlertView: UIViewControllerRepresentable {
    @State private var adjustingText: String = ""
    @Binding var isPresented: Bool
    @Binding var adjustingType: AdjustingType?
    @ObservedObject var viewModel: ReadsViewModel
    let delegate = AlertTextFieldDelegate()
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<UpdatingAlertView>
    ) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<UpdatingAlertView>
    ) {
        guard context.coordinator.alert == nil else { return }
        
        if isPresented {
            var adjustingNumber: Int32 = 0
            let (alertTitle, actionTitle) = viewModel.alertAndActionTitles(for: adjustingType)
            
            let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
            context.coordinator.alert = alert
            
            let positiveAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                viewModel.handleAdjusting(for: adjustingType, with: adjustingNumber)
                alert.dismiss(animated: true) {
                    adjustingType = nil
                    isPresented = false
                }
            }
            
            alert.addTextField { alertTextField in
                alertTextField.placeholder = "Enter number"
                alertTextField.keyboardType = .numberPad
                alertTextField.clearButtonMode = .always
                alertTextField.delegate = delegate
                positiveAction.isEnabled = false
                NotificationCenter.default
                    .addObserver(
                        forName: UITextField.textDidChangeNotification,
                        object: alertTextField,
                        queue: .main
                    ) { _ in
                        if viewModel.isValidUpdatingNumber(
                            for: alertTextField.text,
                            adjustingType: adjustingType
                        ) {
                            positiveAction.isEnabled = true
                            guard
                                let textValue = alertTextField.text,
                                let numberValue = Int32(textValue)
                            else { return }
                            adjustingNumber = numberValue
                        } else {
                            positiveAction.isEnabled = false
                        }
                    }
            }
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsView"),
                style: .default
            ) { _ in
                alert.dismiss(animated: true) {
                    adjustingType = nil
                    isPresented = false
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(positiveAction)
            alert.view.tintColor = Constants.accentColor ?? .systemOrange
            
            DispatchQueue.main.async {
                uiViewController.present(alert, animated: true) {
                    isPresented = false
                    context.coordinator.alert = nil
                }
            }
        }
    }
    
    func makeCoordinator() -> UpdatingAlertView.Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator {
        var alert: UIAlertController?
        var view: UpdatingAlertView
        
        init(_ view: UpdatingAlertView) {
            self.view = view
        }
    }
    
    final class AlertTextFieldDelegate: NSObject, UITextFieldDelegate {
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            guard CharacterSet(charactersIn: "0123456789")
                .isSuperset(of: CharacterSet(charactersIn: string))
            else {
                return false
            }
            return true
        }
    }
}
