import UIKit

class HomeVC: UIViewController {
    private let cv = HomeCV()
    let vm = HomeVM()
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        view = cv
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        cv.tableView.delegate = self
        cv.tableView.dataSource = self
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.endpoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let endpoint = vm.endpoints[indexPath.row]
        cell.textLabel?.text = endpoint.listTitle
        cell.textLabel?.font = .monospacedSystemFont(ofSize: 15, weight: .semibold)
        cell.detailTextLabel?.text = endpoint.url
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        vm.onEndpointSelected?(vm.endpoints[indexPath.row])
    }
}
