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

    /// The element VoiceOver should land on when content appears after a load.
    var accessibilityFocusView: UIView { headerStackView }

    func configure(with details: Details) {
        iconImageView.image = UIImage(systemName: details.icon)
        titleLabel.text = details.title
        subtitleLabel.text = details.subtitle
        subtitleLabel.isHidden = details.subtitle.isEmpty
        headerStackView.isHidden = false

        configureAccessibility(with: details)
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

        setupLargeContentViewer()
    }
}
private extension EndpointDetailsCV {

    // MARK: - Accessibility

    /// Enables the long-press magnifier (the "large content viewer").
    ///
    /// When the user has chosen one of the accessibility text sizes, iOS still
    /// cannot grow everything without breaking layouts. The large content
    /// viewer is the system answer: press and hold an item and iOS shows a
    /// magnified HUD of it in the middle of the screen, updating as the finger
    /// moves between items.
    ///
    /// The interaction goes on the container. It hit-tests down the hierarchy
    /// for views that opted in with `showsLargeContentViewer`, so the header
    /// and the individual rows are all reachable through this single one.
    func setupLargeContentViewer() {
        addInteraction(UILargeContentViewerInteraction())

        headerStackView.showsLargeContentViewer = true
        headerStackView.scalesLargeContentImage = true
    }

    func configureAccessibility(with details: Details) {
        // The icon repeats what the title already says, so it is decorative:
        // hide it from VoiceOver rather than having it announce "image".
        iconImageView.isAccessibilityElement = false

        // Treat the whole header as ONE element. Without this, VoiceOver stops
        // at the title and then again at the subtitle; as a group it reads
        // "Leanne Graham, leanne@example.com" in a single swipe.
        headerStackView.isAccessibilityElement = true
        headerStackView.accessibilityLabel = details.accessibilityLabel
        // `.header` tells VoiceOver this introduces the screen, which also
        // lets users jump straight to it with the rotor.
        headerStackView.accessibilityTraits = .header

        headerStackView.largeContentTitle = details.largeContentTitle
        headerStackView.largeContentImage = UIImage(systemName: details.icon)
    }

    // MARK: - Subviews

    func makeIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }

    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .scaled(size: 18, weight: .semibold, textStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    func makeSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .scaled(size: 14, weight: .regular, textStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
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
