import UIKit
import Combine

final class UsersVC: ViewController<UsersCV, UsersVM> {
    override func viewDidLoad() {
        super.viewDidLoad()
        data(isLoading: true)
        viewModel.getUsers()
    }
    
    override func setupCV() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }
    
    override func addObservers() {
        viewModel.successGetUsers.sink { [weak self] _ in
            guard let self = self else { return }
            self.contentView.tableView.reloadData()
            self.data(isLoading: false)
        }
        .store(in: &bag)
        
        viewModel.errorMessage.sink { [weak self] message in
            guard let self = self else { return }
            self.data(isLoading: false)
        }
        .store(in: &bag)
    }
}

extension UsersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let user = viewModel.users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.onUserSelected?(viewModel.users[indexPath.row])
    }
}
