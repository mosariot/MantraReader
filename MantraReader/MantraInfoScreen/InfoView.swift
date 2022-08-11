//
//  InfoView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct InfoView: View {
    @ObservedObject private var viewModel: InfoViewModel
    @State private var infoMode: InfoMode
    @Binding private var isPresented: Bool
    
    init(viewModel: InfoViewModel, infoMode: InfoMode, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._infoMode = State(initialValue: infoMode)
        self._isPresented = isPresented
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
                        TextField("Enter mantra title", text: $viewModel.title)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .padding()
                            .disabled(infoMode == .view)
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
                        TextField("Enter mantra text", text: $viewModel.text)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .padding()
                            .disabled(infoMode == .view)
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
                        TextEditor(text: $viewModel.description)
                            .font(.title2)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 11)
                            .padding(.top, 44)
                            .padding(.bottom, 10)
                            .disabled(infoMode == .view)
                    }
                    .padding()
                }
                .navigationTitle(infoMode == .addNew ? "New Mantra" : "Information")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                if infoMode == .edit || infoMode == .view {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .symbolVariant(.circle.fill)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                }
                if infoMode == .edit {
                     ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            infoMode = .view
                            viewModel.saveMantra()
                        } label: {
                            Text("Done")
                                .bold()
                        }
                        .disabled(viewModel.title.isEmpty)
                    }
                }
                if infoMode == .view {
                     ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            infoMode = .edit
                        }
                    }
                }
                if infoMode == .addNew {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            viewModel.deleteNewMantra()
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.saveMantra()
                            isPresented = false
                        } label: {
                            Text("Add")
                                .bold()
                        }
                        .disabled(viewModel.title.isEmpty)
                    }
                }
            }
            .onReceive(of: viewModel.mantra.objectWillChange) { _ in
                if infoMode == .view {
                    viewModel.updateUI()
                }
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InfoView(
                viewModel: InfoViewModel(
                    PersistenceController.previewMantra,
                    viewContext: PersistenceController.preview.container.viewContext
                ),
                infoMode: .constant(.edit),
                isPresented: .constant(true)
            )
        }
    }
}
