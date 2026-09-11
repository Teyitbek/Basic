import UIKit
import Combine

final class EndpointDetailsVC: ViewController<EndpointDetailsCV, EndpointDetailsVM> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        
        if viewModel.isReady {
            showDetails()
        } else {
            data(isLoading: true)
            viewModel.getDetails()
        }
    }
    
    override func setupCV() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }
    
    override func addObservers() {
        viewModel.successGetDetails.sink { [weak self] _ in
            guard let self = self else { return }
            self.data(isLoading: false)
            self.showDetails()
        }
        .store(in: &bag)
        
        viewModel.errorMessage.sink { [weak self] message in
            guard let self = self else { return }
            self.data(isLoading: false)
            self.show(error: message)
        }
        .store(in: &bag)
    }
    
    private func showDetails() {
        guard let details = viewModel.details else { return }
        contentView.configure(with: details)
    }
    
    private func show(error: String) {
        let alert = UIAlertController(title: "Something went wrong", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

extension EndpointDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.details?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.details?.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.details?.sections[section].rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        guard let row = viewModel.details?.sections[indexPath.section].rows[indexPath.row] else { return cell }
        cell.textLabel?.text = row.title
        cell.textLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        cell.textLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.text = row.value
        cell.detailTextLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cell.detailTextLabel?.textColor = .label
        cell.detailTextLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        return cell
    }
}
