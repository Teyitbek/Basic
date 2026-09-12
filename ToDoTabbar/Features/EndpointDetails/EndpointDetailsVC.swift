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
            // The screen was empty while loading, so VoiceOver has nothing
            // useful focused. `.screenChanged` makes it announce the content
            // that just arrived and move focus to the header.
            UIAccessibility.post(notification: .screenChanged,
                                 argument: self.contentView.accessibilityFocusView)
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
        cell.textLabel?.font = .scaled(size: 12, weight: .regular, textStyle: .caption1)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.textColor = .secondaryLabel
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = row.value
        cell.detailTextLabel?.font = .scaled(size: 16, weight: .regular, textStyle: .body)
        cell.detailTextLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.textColor = .label
        cell.detailTextLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        configureAccessibility(of: cell, with: row)
        return cell
    }

    /// A cell built from two labels is read by VoiceOver as two separate
    /// pieces of text. Naming the field as the *label* and the content as the
    /// *value* instead makes it announce "Username, Bret" as one item — and a
    /// value is re-announced on its own when it changes.
    ///
    /// The same row also opts in to the long-press magnifier; the interaction
    /// that drives it lives on the content view.
    private func configureAccessibility(of cell: UITableViewCell, with row: DetailsRow) {
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = row.accessibilityLabel
        cell.accessibilityValue = row.accessibilityValue

        cell.showsLargeContentViewer = true
        cell.largeContentTitle = row.largeContentTitle
    }
}
