//
//  InfoView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct InfoView: View {
    @State var title: String = ""
    @State var text: String = ""
    @State var description: String = ""
    
    init() {
        UITextField.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                ScrollView {
                    Image("DefaultImage")
                        .accessibilityIgnoresInvertColors()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("TITLE")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter mantra title", text: $title)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .padding()
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("MANTRA TEXT")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter mantra text", text: $text)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .padding()
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding()
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                        Text("DESCRIPTION")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        if description.isEmpty {
                            Text("Enter mantra description")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.horizontal, 15)
                                .padding(.top, 52)
                                .padding(.bottom, 16)
                        }
                        TextEditor(text: $description)
                            .font(.title2)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 11)
                            .padding(.top, 44)
                            .padding(.bottom, 10)
                    }
                    .padding()
                }
                .navigationTitle("Information")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InfoView()
        }
    }
}
