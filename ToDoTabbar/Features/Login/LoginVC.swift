import UIKit
import Combine

final class LoginVC: ViewController<LoginCV, LoginVM> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
    }
    
    override func setupCV() {
        contentView.loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        [contentView.nameField, contentView.emailField, contentView.passwordField].forEach { $0.delegate = self }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)
    }
    
    override func addObservers() {
        viewModel.nameError.sink { [weak self] message in
            self?.contentView.show(nameError: message)
        }
        .store(in: &bag)
        
        viewModel.emailError.sink { [weak self] message in
            self?.contentView.show(emailError: message)
        }
        .store(in: &bag)
        
        viewModel.passwordError.sink { [weak self] message in
            self?.contentView.show(passwordError: message)
        }
        .store(in: &bag)
    }
    
    @objc
    private func didTapLogin() {
        dismissKeyboard()
        viewModel.login(name: contentView.nameField.text,
                        email: contentView.emailField.text,
                        password: contentView.passwordField.text)
    }
    
    @objc
    private func dismissKeyboard() {
        contentView.endEditing(true)
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contentView.nameField:
            contentView.emailField.becomeFirstResponder()
        case contentView.emailField:
            contentView.passwordField.becomeFirstResponder()
        default:
            didTapLogin()
        }
        return true
    }
}
