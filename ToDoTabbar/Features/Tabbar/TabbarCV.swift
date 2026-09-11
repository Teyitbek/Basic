import UIKit

class TabbarCV: UIView {
    lazy var containerView = makeContainerView()
    lazy var tabBarView = makeCustomTabBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupViews() {
        backgroundColor = .systemBackground
        [containerView, tabBarView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubview(containerView)
        addSubview(tabBarView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor),
            
            tabBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
private extension TabbarCV {
    func makeContainerView() -> UIView {
        return UIView()
    }
    
    func makeCustomTabBar() -> CustomTabBar {
        return CustomTabBar()
    }
}
