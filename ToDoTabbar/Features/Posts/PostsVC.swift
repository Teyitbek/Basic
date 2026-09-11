import UIKit
import Combine

final class PostsVC: ViewController<PostsCV, PostsVM> {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        data(isLoading: true)
        viewModel.getPosts()
    }
    
    override func setupCV() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }
    
    override func addObservers() {
        viewModel.successGetPosts.sink { [weak self] _ in
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

extension PostsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let post = viewModel.posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = "Post #\(post.id)"
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.onPostSelected?(viewModel.posts[indexPath.row])
    }
}
