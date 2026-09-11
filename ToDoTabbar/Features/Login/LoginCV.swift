import UIKit

final class LoginCV: UIView {
    lazy var nameField = makeTextField(placeholder: "Name", contentType: .name)
    lazy var emailField = makeTextField(placeholder: "Email", contentType: .emailAddress)
    lazy var passwordField = makeTextField(placeholder: "Password", contentType: .password)
    lazy var loginButton = makeLoginButton()
    
    private lazy var titleLabel = makeTitleLabel()
    private lazy var nameErrorLabel = makeErrorLabel()
    private lazy var emailErrorLabel = makeErrorLabel()
    private lazy var passwordErrorLabel = makeErrorLabel()
    private lazy var stackView = makeStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(nameError: String?) {
        apply(nameError, to: nameErrorLabel, field: nameField)
    }
    
    func show(emailError: String?) {
        apply(emailError, to: emailErrorLabel, field: emailField)
    }
    
    func show(passwordError: String?) {
        apply(passwordError, to: passwordErrorLabel, field: passwordField)
    }
}
extension LoginCV: CVProtocol {
    override func setupViews() {
        backgroundColor = .systemBackground
        
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        
        nameField.returnKeyType = .next
        emailField.returnKeyType = .next
        passwordField.returnKeyType = .done
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        [titleLabel,
         nameField, nameErrorLabel,
         emailField, emailErrorLabel,
         passwordField, passwordErrorLabel,
         loginButton].forEach { stackView.addArrangedSubview($0) }
        
        stackView.setCustomSpacing(24, after: titleLabel)
        stackView.setCustomSpacing(16, after: nameErrorLabel)
        stackView.setCustomSpacing(16, after: emailErrorLabel)
        stackView.setCustomSpacing(24, after: passwordErrorLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            nameField.heightAnchor.constraint(equalToConstant: 48),
            emailField.heightAnchor.constraint(equalToConstant: 48),
            passwordField.heightAnchor.constraint(equalToConstant: 48),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
private extension LoginCV {
    func apply(_ message: String?, to label: UILabel, field: UITextField) {
        label.text = message
        label.isHidden = message == nil
        field.layer.borderColor = (message == nil ? UIColor.separator : UIColor.systemRed).cgColor
    }
    
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Sign In"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }
    
    func makeTextField(placeholder: String, contentType: UITextContentType) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.textContentType = contentType
        field.borderStyle = .none
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.separator.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        return field
    }
    
    func makeErrorLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }
    
    func makeLoginButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }
    
    func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .fill
        return stackView
    }
}
