import UIKit

final class EndpointDetailsCV: UIView {
    lazy var tableView = makeTableView()
    
    private lazy var iconImageView = makeIconImageView()
    private lazy var titleLabel = makeTitleLabel()
    private lazy var subtitleLabel = makeSubtitleLabel()
    private lazy var headerStackView = makeHeaderStackView()
    
    private let iconSize: CGFloat = 80
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with details: Details) {
        iconImageView.image = UIImage(systemName: details.icon)
        titleLabel.text = details.title
        subtitleLabel.text = details.subtitle
        subtitleLabel.isHidden = details.subtitle.isEmpty
        headerStackView.isHidden = false
        tableView.reloadData()
    }
}
extension EndpointDetailsCV: CVProtocol {
    override func setupViews() {
        backgroundColor = .systemBackground
        headerStackView.isHidden = true
        
        [headerStackView, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        [iconImageView, titleLabel, subtitleLabel].forEach { headerStackView.addArrangedSubview($0) }
        headerStackView.setCustomSpacing(12, after: iconImageView)
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            headerStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            headerStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
            
            tableView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
private extension EndpointDetailsCV {
    func makeIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }
    
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    func makeSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    func makeHeaderStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .fill
        return stackView
    }
    
    func makeTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.backgroundColor = .systemBackground
        return tableView
    }
}
