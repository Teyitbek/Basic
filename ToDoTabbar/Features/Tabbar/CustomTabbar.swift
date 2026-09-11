import UIKit

class CustomTabBar: UIView {
    
    var onTabSelected: ((Int) -> Void)?
    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    
    private let items: [(icon: String, title: String)] = [
        ("house", "Home"),
        ("person", "Profile"),
        ("gearshape", "Settings"),
        ("message.fill", "Messages")
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupButtons()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    private func setupButtons() {
        for (index, item) in items.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.tintColor = .gray
            button.setTitleColor(.gray, for: .normal)
            
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
            let icon = UIImage(systemName: item.icon, withConfiguration: config)
            button.setImage(icon, for: .normal)
            button.setTitle(" " + item.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.addTarget(self, action: #selector(tabPressed(_:)), for: .touchUpInside)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        updateSelection()
    }
    
    @objc private func tabPressed(_ sender: UIButton) {
        onTabSelected?(sender.tag)
    }
    
    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            let isSelected = (index == selectedIndex)
            button.tintColor = isSelected ? .systemBlue : .gray
            button.setTitleColor(isSelected ? .systemBlue : .gray, for: .normal)
        }
    }
}
