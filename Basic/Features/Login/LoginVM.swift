import Foundation

@Observable
final class LoginVM {
    // The view binds straight to these, so the fields live here rather than
    // in the view's own @State.
    var name = ""
    var email = ""
    var password = ""

    private(set) var nameError: String?
    private(set) var emailError: String?
    private(set) var passwordError: String?

    private let minNameLength = 2
    private let minPasswordLength = 6
    private let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    /// Validates every field and reports whether the user may continue.
    /// All three are checked on each attempt, so fixing one field clears its
    /// message while any remaining problems stay visible.
    @discardableResult
    func login() -> Bool {
        nameError = validateName(name.trimmed)
        emailError = validateEmail(email.trimmed)
        passwordError = validatePassword(password)

        return nameError == nil && emailError == nil && passwordError == nil
    }
}
private extension LoginVM {
    func validateName(_ name: String) -> String? {
        if name.isEmpty { return "Name is required" }
        if name.count < minNameLength { return "Name must be at least \(minNameLength) characters" }
        return nil
    }

    func validateEmail(_ email: String) -> String? {
        if email.isEmpty { return "Email is required" }
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        return isValid ? nil : "Enter a valid email"
    }

    func validatePassword(_ password: String) -> String? {
        if password.isEmpty { return "Password is required" }
        if password.count < minPasswordLength { return "Password must be at least \(minPasswordLength) characters" }
        guard password.contains(where: { $0.isLetter }), password.contains(where: { $0.isNumber }) else {
            return "Password must contain a letter and a number"
        }
        return nil
    }
}
