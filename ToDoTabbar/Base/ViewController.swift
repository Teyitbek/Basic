import Combine
import UIKit

class ViewController<ContentView: CVProtocol, ViewModel: VMProtocol>: UIViewController {
    var bag = Set<AnyCancellable>()
    
    private lazy var activityIndicator = makeActivityIndicator()
    
    var contentView: ContentView
    var viewModel: ViewModel
    
    init(contentView: ContentView, viewModel: ViewModel) {
        self.contentView = contentView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        addObservers()
        setupCV()
        setupVM()
    }
    
    deinit {
        bag.removeAll()
    }
    
    func addObservers() {}
    func setupCV() {}
    func setupVM() {}
    
    func data(isLoading: Bool) {
        view.isUserInteractionEnabled = !isLoading
        navigationController?.navigationBar.isUserInteractionEnabled = !isLoading
        tabBarController?.tabBar.isUserInteractionEnabled = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
private extension ViewController {
    func makeActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .label
        return activityIndicator
    }
}
