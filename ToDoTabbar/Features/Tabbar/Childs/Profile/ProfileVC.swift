import UIKit

class ProfileVC: UIViewController {
    private let cv = ProfileCV()
    let vm = ProfileVM()
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        view = cv
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        
        cv.imageView.image = UIImage(systemName: "person.fill")
    }
}
