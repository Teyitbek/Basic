import UIKit

class SettingsVC: UIViewController {
    private let cv = SettingsCV()
    let vm = SettingsVM()
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        view = cv
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        cv.imageView.image = UIImage(systemName: "person.crop.circle")
    }
}
