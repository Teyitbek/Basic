import UIKit
import SwiftUI

class TabbarVC: UIViewController {
    private let cv = TabbarCV()
    
    let homeVC = HomeVC()
    let profileVC = ProfileVC()
    let settingsVC = SettingsVC()
    let messagesView = UIHostingController(rootView: MessagesView())
    
    private var currentVC: UIViewController?
    private var viewControllers: [UIViewController] = []
    
    override func loadView() {
        self.view = cv
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [homeVC, profileVC, settingsVC, messagesView]
        setupActions()
        selectTab(index: 0)
    }
    
    private func setupActions() {
        cv.tabBarView.onTabSelected = { [weak self] index in
            self?.selectTab(index: index)
        }
    }
    
    private func selectTab(index: Int) {
        // Remove previous VC
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        
        // Add new VC
        let vc = viewControllers[index]
        addChild(vc)
        cv.containerView.addSubview(vc.view)
        vc.view.frame = cv.containerView.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParent: self)
        
        currentVC = vc
        cv.tabBarView.selectedIndex = index
    }
}
