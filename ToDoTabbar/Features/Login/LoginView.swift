import SwiftUI

struct LoginView: View {
    /// The one thing this screen cannot decide for itself: what happens after
    /// a successful login. The owner of the app's root state supplies it.
    let onLoginSuccess: () -> Void

    @State private var viewModel = LoginVM()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name, email, password
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Sign In")
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity)

            field(error: viewModel.nameError) {
                TextField("Name", text: $viewModel.name)
                    .textContentType(.name)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit { focusedField = .email }
            }
            .padding(.top, 24)

            field(error: viewModel.emailError) {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }
            }
            .padding(.top, 16)

            field(error: viewModel.passwordError) {
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .password)
                    .onSubmit(submit)
            }
            .padding(.top, 16)

            Button(action: submit) {
                Text("Login")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.accentColor, in: .rect(cornerRadius: 8))
            }
            .padding(.top, 24)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        // Tap anywhere off the fields to dismiss the keyboard.
        .contentShape(.rect)
        .onTapGesture { focusedField = nil }
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// A text field with its error message underneath. The red border and the
    /// message appear together, so they are built in one place.
    private func field<Content: View>(error: String?,
                                      @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            content()
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(error == nil ? Color(.separator) : .red, lineWidth: 1)
                }

            if let error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func submit() {
        focusedField = nil
        if viewModel.login() {
            onLoginSuccess()
        }
    }
}

#Preview {
    NavigationStack {
        LoginView(onLoginSuccess: {})
    }
}
