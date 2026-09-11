import Foundation
import Combine

final class LoginVM: VMProtocol {
    var onLoginSuccess: SimpleNavigation?
    
    let nameError = CurrentValueSubject<String?, Never>(nil)
    let emailError = CurrentValueSubject<String?, Never>(nil)
    let passwordError = CurrentValueSubject<String?, Never>(nil)
    
    private let minNameLength = 2
    private let minPasswordLength = 6
    private let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    func login(name: String?, email: String?, password: String?) {
        let name = name?.trimmed ?? ""
        let email = email?.trimmed ?? ""
        let password = password ?? ""
        
        nameError.send(validateName(name))
        emailError.send(validateEmail(email))
        passwordError.send(validatePassword(password))
        
        guard nameError.value == nil,
              emailError.value == nil,
              passwordError.value == nil
        else { return }
        
        onLoginSuccess?()
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
