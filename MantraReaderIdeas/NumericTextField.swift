//
//  NumericTextField.swift
//  MantraReaderIdeas
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct NumericTextField: View {
    private let placeHolder: String
    @Binding private var text: String
    
    init(_ placeHolder: String, text: Binding<String>) {
        self.placeHolder = placeHolder
        self._text = text
    }
    
    var body: some View {
        TextField(placeHolder, text: $text)
            .textFieldStyle(.roundedBorder)
            .onChange(of: text) { newValue in
                let filtered = newValue.filter { "-0123456789".contains($0)}
                if filtered != newValue {
                    text = filtered
                }
            }
            .keyboardType(.numberPad)
    }
}

struct NumericTextField_Previews: PreviewProvider {
    static var previews: some View {
        NumericTextField("Enter Some Value", text: .constant(""))
            .frame(width: 200)
    }
}
