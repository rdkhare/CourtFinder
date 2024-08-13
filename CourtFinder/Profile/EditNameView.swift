//
//  EditNameView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/20/24.
//

import SwiftUI

struct EditNameView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var newName: String
    @State private var isEditing: Bool = false
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: ProfileViewModel, newName: String) {
        self.viewModel = viewModel
        _newName = State(initialValue: newName)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Name")
                    .foregroundColor(.gray)
                Spacer()
                ZStack(alignment: .trailing) {
                    TextField("", text: $newName, onEditingChanged: { editing in
                        isEditing = editing
                    })
                    .disableAutocorrection(true)
                    .autocapitalization(.words)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(.trailing, 30) // Add padding to the right
                    .background(Color.clear)
                    .border(Color.clear)
                    .onTapGesture {
                        self.isEditing = true
                    }
                    .overlay(
                        HStack {
                            Spacer()
                            if isEditing {
                                Button(action: {
                                    self.newName = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 5) // Adjust padding to position the button
                            }
                        }
                    )
                }
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .navigationTitle("Edit Name")
        .navigationBarItems(trailing: Button("Done") {
            if !newName.isEmpty {
                viewModel.updateUserName(newName)
                presentationMode.wrappedValue.dismiss()
            } else {
                showAlert = true
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Name cannot be empty"), dismissButton: .default(Text("OK")))
        }
    }
}

