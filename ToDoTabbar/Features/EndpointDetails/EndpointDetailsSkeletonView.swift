import UIKit

/// Placeholder shown while the details are loading.
///
/// The blocks deliberately mirror the real layout — icon, title, subtitle,
/// then rows — so the screen keeps its shape and nothing jumps when the
/// content arrives.
final class EndpointDetailsSkeletonView: UIView {

    /// One full sweep of the shimmer.
    static let shimmerDuration: TimeInterval = 1

    private lazy var iconBlock = makeBlock(height: 80, cornerRadius: 40)
    private lazy var titleBlock = makeBlock(height: 22)
    private lazy var subtitleBlock = makeBlock(height: 16)
    private lazy var headerStackView = makeStackView(spacing: 10, alignment: .center)
    private lazy var rowsStackView = makeStackView(spacing: 22, alignment: .fill)
    private lazy var contentStackView = makeStackView(spacing: 28, alignment: .fill)

    /// Sweeps across the whole view as a mask, so every block lights up
    /// together rather than each animating on its own.
    private let shimmerMask = CAGradientLayer()

    private let rowCount = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Layers are not laid out by Auto Layout, so the mask is sized by hand.
        shimmerMask.frame = bounds
    }

    func startAnimating() {
        // A moving shimmer is exactly what Reduce Motion asks us not to do.
        // The blocks alone still read as "loading".
        guard !UIAccessibility.isReduceMotionEnabled else { return }

        layer.mask = shimmerMask

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = Self.shimmerDuration
        animation.repeatCount = .infinity
        shimmerMask.add(animation, forKey: "shimmer")
    }

    func stopAnimating() {
        shimmerMask.removeAllAnimations()
        layer.mask = nil
    }
}

extension EndpointDetailsSkeletonView: CVProtocol {
    override func setupViews() {
        backgroundColor = .systemBackground

        // VoiceOver should say the screen is busy, not read out a pile of
        // meaningless empty shapes.
        isAccessibilityElement = true
        accessibilityLabel = "Loading"
        accessibilityTraits = .updatesFrequently

        setupShimmerMask()

        [headerStackView, rowsStackView].forEach { contentStackView.addArrangedSubview($0) }
        [iconBlock, titleBlock, subtitleBlock].forEach { headerStackView.addArrangedSubview($0) }
        (0..<rowCount).forEach { _ in rowsStackView.addArrangedSubview(makeRow()) }

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),

            iconBlock.widthAnchor.constraint(equalToConstant: 80),
            titleBlock.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.7),
            subtitleBlock.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.4)
        ])
    }
}

private extension EndpointDetailsSkeletonView {
    func setupShimmerMask() {
        // As a mask these colours are read as alpha: the blocks sit at 40%
        // and a fully opaque band travels across them.
        shimmerMask.colors = [
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor
        ]
        shimmerMask.locations = [0, 0.5, 1]
        shimmerMask.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerMask.endPoint = CGPoint(x: 1, y: 0.5)
    }

    /// One row of the table: a short caption above a longer value.
    func makeRow() -> UIView {
        let captionBlock = makeBlock(height: 10)
        let valueBlock = makeBlock(height: 18)

        let stackView = makeStackView(spacing: 8, alignment: .leading)
        [captionBlock, valueBlock].forEach { stackView.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            captionBlock.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.25),
            valueBlock.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.6)
        ])
        return stackView
    }

    func makeBlock(height: CGFloat, cornerRadius: CGFloat = 6) -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.layer.cornerRadius = cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }

    func makeStackView(spacing: CGFloat, alignment: UIStackView.Alignment) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.alignment = alignment
        return stackView
    }
}
