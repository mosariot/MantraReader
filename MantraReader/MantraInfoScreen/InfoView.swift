//
//  InfoView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.07.2022.
//

import SwiftUI
import Combine
import PhotosUI

struct InfoView: View {
    private enum FocusableField: Hashable {
        case title
        case text
        case round
        case description
    }
    
    @AppStorage("isFirstSearchOnTheInternet") private var isFirstSearchOnTheInternet = true
    @EnvironmentObject private var dataManager: DataManager
    @StateObject private var viewModel: InfoViewModel
    @State private var infoMode: InfoMode
    @Binding private var isPresented: Bool
    @State private var isPresentedChangesAlert = false
    @State private var isPresentedDiscardingMantraAlert = false
    @State private var isPresentedDuplicationAlert = false
    @State private var isPresentedSafariController = false
    @State private var isPresentedFirstSearchOnTheInternetAlert = false
    @State private var isProcessingImage = false
// Native PhotoPicker code -start-
//    @State private var selectedPhotoItem: PhotosPickerItem?
// Native PhotoPicker code -start-
// Old PHPicker code -start-
    @State private var isPresentedImagePickerView = false
    @State private var selectedPhoto: UIImage?
// Old PHPicker code -end-
    @State private var isPresentedNoImageAlert = false
    @State private var successfullyAdded = false
    @FocusState private var focus: FocusableField?
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
    init(viewModel: InfoViewModel, infoMode: InfoMode, isPresented: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
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
                    ZStack {
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .opacity(infoMode == .edit || infoMode == .addNew ? 0.7 : 1)
                            .accessibilityIgnoresInvertColors()
                            .overlay(alignment: .bottom) {
                                Menu {
// Old PHPicker code -start-
                                    Button {
                                        focus = nil
                                        isPresentedImagePickerView = true
                                    } label: {
                                        Label("Photo Library", systemImage: "photo.on.rectangle.angled")
                                    }
// Old PHPicker code -end-
// Native PhotoPicker code -start-
//                                    PhotosPicker(
//                                        selection: $selectedPhotoItem,
//                                        matching: .images,
//                                        photoLibrary: .shared()
//                                    ) {
//                                        Label("Photo Library", systemImage: "photo.on.rectangle.angled")
//                                    }
//                                    .onChange(of: selectedPhotoItem) { item in
//                                        Task {
//                                            isProcessingImage = true
//                                            if let data = try? await item?.loadTransferable(type: Data.self) {
//                                                if let image = UIImage(data: data) {
//                                                    withAnimation {
//                                                        viewModel.handleIncomingImage(image)
//                                                    }
//                                                } else {
//                                                    isPresentedNoImageAlert = true
//                                                }
//                                            } else {
//                                                isPresentedNoImageAlert = true
//                                            }
//                                            isProcessingImage = false
//                                        }
//                                    }
// Native PhotoPicker code -end-
                                    Button {
                                        focus = nil
                                        withAnimation {
                                            viewModel.setDefaultImage()
                                        }
                                    } label: {
                                        Label("Default Image", systemImage: "photo")
                                    }
                                    Button {
                                        focus = nil
                                        if isFirstSearchOnTheInternet {
                                            isPresentedFirstSearchOnTheInternetAlert = true
                                        } else {
                                            isPresentedSafariController = true
                                        }
                                    } label: {
                                        Label("Search on the Internet", systemImage: "globe")
                                    }
                                    .onChange(of: isPresentedSafariController) { [oldValue = isPresentedSafariController] newValue in
                                        if oldValue && !newValue {
                                            if UIPasteboard.general.hasImages {
                                                guard let image = UIPasteboard.general.image else { return }
                                                withAnimation {
                                                    viewModel.handleIncomingImage(image)
                                                }
                                                UIPasteboard.general.items.removeAll()
                                            } else if UIPasteboard.general.hasURLs {
                                                guard let url = UIPasteboard.general.url else { return }
                                                if let data = try? Data(contentsOf: url) {
                                                    if let image = UIImage(data: data) {
                                                        withAnimation {
                                                            viewModel.handleIncomingImage(image)
                                                        }
                                                        UIPasteboard.general.items.removeAll()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(.gray)
                                            .frame(width: 200, height: 30)
                                        Text("EDIT")
                                            .foregroundColor(.white.opacity(0.8))
                                            .font(.headline.bold())
                                    }
                                }
                                .opacity(infoMode == .edit || infoMode == .addNew ? 0.8 : 0)
                            }
                            .padding(.top, 10)
                        if isProcessingImage {
                            ProgressView()
                        }
                    }
                    .alert("Unavailable Photo", isPresented: $isPresentedNoImageAlert) {
                        Button("OK") {
                            isProcessingImage = false
// Old PHPicker code -start-
                            isPresentedImagePickerView = true
// Old PHPicker code -end-
                        }
                    } message: {
                        Text("It seems like this photo is unavailable. Try to pick another one.")
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("TITLE")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter mantra title", text: $viewModel.title, axis: .vertical)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .focused($focus, equals: .title)
                            .padding()
                            .disabled(infoMode == .view)
                            .onSubmit { focus = .text }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("MANTRA TEXT")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter mantra text", text: $viewModel.text, axis: .vertical)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .focused($focus, equals: .text)
                            .textInputAutocapitalization(.characters)
                            .padding()
                            .disabled(infoMode == .view)
                            .onSubmit { focus = .round }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("READINGS IN ROUND")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter number", text: $viewModel.round)
                            .font(.title2)
                            .autocorrectionDisabled()
                            .keyboardType(.numberPad)
                            .onReceive(Just(viewModel.round)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    viewModel.round = filtered
                                }
                            }
                            .focused($focus, equals: .round)
                            .padding()
                            .disabled(infoMode == .view)
                            .onSubmit { focus = .description }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DESCRIPTION")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                        TextField("Enter mantra description", text: $viewModel.description, axis: .vertical)
                            .font(.title2)
                            .focused($focus, equals: .description)
                            .padding()
                            .disabled(infoMode == .view)
                            .onSubmit { focus = nil }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding()
                }
                if successfullyAdded {
                    CheckMarkView()
                }
            }
            .navigationTitle(infoMode == .addNew ? "New Mantra" : "Information")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Pick Photo", isPresented: $isPresentedFirstSearchOnTheInternetAlert) {
                Button("OK") {
                    isFirstSearchOnTheInternet = false
                    isPresentedSafariController = true
                }
            } message: {
                Text("Search for image in the next window. Then just longpress on the one you liked, choose 'Copy' in contextual menu and confirm it by 'Done'")
            }
            .sheet(isPresented: $isPresentedSafariController) {
                SafariView(
                    url: URL(string: "https://www.google.com/search?q=\(viewModel.title)&tbm=isch"
                        .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
                )
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
                .ignoresSafeArea()
            }
// Old PHPicker code -start-
            .sheet(isPresented: $isPresentedImagePickerView) {
                ImagePickerView(
                    image: $selectedPhoto,
                    isProcessingImage: $isProcessingImage,
                    isPresentedNoImageAlert: $isPresentedNoImageAlert
                )
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
                .ignoresSafeArea()
            }
            .onChange(of: selectedPhoto) { image in
                guard let image else { return }
                withAnimation {
                    viewModel.handleIncomingImage(image)
                    isProcessingImage = false
                }
            }
// Old PHPicker code -end-
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if infoMode == .edit || infoMode == .view {
                        Button {
                            if infoMode == .edit && viewModel.areThereSomeChanges {
                                isPresentedChangesAlert = true
                            } else {
                                isPresented = false
                            }
                        } label: {
                            CloseButtonImage()
                        }
                        .confirmationDialog(
                            "There were some changes",
                            isPresented: $isPresentedChangesAlert,
                            titleVisibility: .hidden
                        ) {
                            Button("Discard Changes", role: .destructive) {
                                isPresented = false
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Are you sure you want to discard changes?")
                        }
                    }
                    if infoMode == .addNew {
                        Button("Cancel") {
                            if viewModel.isCleanMantra {
                                dataManager.deleteEmptyMantrasIfNeeded()
                                isPresented = false
                            } else {
                                isPresentedDiscardingMantraAlert = true
                            }
                        }
                        .confirmationDialog(
                            "Discarding Mantra",
                            isPresented: $isPresentedDiscardingMantraAlert,
                            titleVisibility: .hidden
                        ) {
                            Button("Discard Mantra", role: .destructive) {
                                dataManager.deleteEmptyMantrasIfNeeded()
                                isPresented = false
                            }
                        } message: {
                            Text("Are you sure you want to discard this Mantra?")
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if infoMode == .edit {
                        Button {
                            withAnimation {
                                infoMode = .view
                            }
                            viewModel.saveMantraIfNeeded()
                        } label: {
                            Text("Done")
                                .bold()
                        }
                        .disabled(viewModel.title.trimmingCharacters(in: .whitespaces) == "")
                    }
                    if infoMode == .view {
                        Button("Edit") {
                            withAnimation {
                                infoMode = .edit
                            }
                            focus = .title
                        }
                    }
                    if infoMode == .addNew {
                        Button {
                            if !viewModel.isDuplicating {
                                addMantra()
                            } else {
                                isPresentedDuplicationAlert = true
                            }
                        } label: {
                            Text("Add")
                                .bold()
                        }
                        .disabled(viewModel.title.trimmingCharacters(in: .whitespaces) == "")
                        .confirmationDialog(
                            "Duplicating Mantra",
                            isPresented: $isPresentedDuplicationAlert,
                            titleVisibility: .visible
                        ) {
                            Button("Add") {
                                addMantra()
                            }
                        } message: {
                            Text("It's already in your mantra list. Add another one?")
                        }
                    }
                }
            }
            .onReceive(viewModel.mantra.objectWillChange) { _ in
                if infoMode == .view {
                    viewModel.updateFields()
                }
            }
            .onAppear {
                if infoMode == .addNew {
                    focus = .title
                }
            }
            .onDisappear {
                viewModel.updateFields()
                if infoMode == .addNew {
                    dataManager.deleteEmptyMantrasIfNeeded()
                }
            }
        }
        .disabled(successfullyAdded)
    }
    
    private func addMantra() {
        withAnimation {
            viewModel.saveMantraIfNeeded(withCleanUp: true)
            addHapticGenerator.notificationOccurred(.success)
            successfullyAdded = true
            afterDelay(0.7) { isPresented = false }
        }
    }
}
