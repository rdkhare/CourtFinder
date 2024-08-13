//
//  EditUsernameView.swift
//  CourtFinder
//
//  Created by Rajat Khare on 7/20/24.
//

import SwiftUI

struct EditUsernameView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var newUsername: String
    @State private var isEditing: Bool = false
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: ProfileViewModel, newUsername: String) {
        self.viewModel = viewModel
        _newUsername = State(initialValue: newUsername)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Username")
                    .foregroundColor(.gray)
                Spacer()
                ZStack(alignment: .trailing) {
                    TextField("", text: $newUsername, onEditingChanged: { editing in
                        isEditing = editing
                    })
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
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
                                    self.newUsername = ""
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
        .navigationTitle("Username")
        .navigationBarItems(trailing: Button("Done") {
            if !newUsername.isEmpty {
                viewModel.updateUserUsername(newUsername)
                presentationMode.wrappedValue.dismiss()
            } else {
                showAlert = true
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Username cannot be empty"), dismissButton: .default(Text("OK")))
        }
    }
}




