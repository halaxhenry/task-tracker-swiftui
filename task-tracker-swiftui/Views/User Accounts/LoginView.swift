//
//  LoginView.swift
//  task-tracker-swiftui
//
//  Created by Andrew Morgan on 03/11/2020.
//

import SwiftUI
import RealmSwift

struct LoginView: View {
//    @Binding var user: User?

    @EnvironmentObject var state: AppState
    @State private var username = ""
    @State private var password = ""

    private enum Dimensions {
        static let padding: CGFloat = 16.0
    }

    var body: some View {
        VStack(spacing: Dimensions.padding) {
            InputField(title: "Email/Username",
                       text: self.$username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            InputField(title: "Password",
                       text: self.$password,
                       showingSecureField: true)
            CallToActionButton(
                title: "Log In",
                action: { self.login(username: self.username, password: self.password) })
            NavigationLink(
                destination: SignupView(),
                label: {
                    Text("Register new user")
                })        }
        .padding(.horizontal, Dimensions.padding)
    }

    private func login(username: String, password: String) {
        if username.isEmpty || password.isEmpty {
            return
        }
        self.state.error = nil
        state.shouldIndicateActivity = true
        app.login(credentials: .emailPassword(email: username, password: password))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                state.shouldIndicateActivity = false
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    self.state.error = error.localizedDescription
                }
            }, receiveValue: {
                self.state.error = nil
                state.loginPublisher.send($0)
            })
            .store(in: &state.cancellables)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .environmentObject(AppState())
            LoginView()
                .preferredColorScheme(.dark)
                .environmentObject(AppState())
        }
    }
}
