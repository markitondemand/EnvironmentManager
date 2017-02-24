//  Copyright © 2017 Markit. All rights reserved.
//

import UIKit


extension EnvironmentManager {
    static let StoryboardName = "EnvironmentManagerStoryboard"
    
    /// Generates a simple UI to represent and interact with the TestAccountManager. This is not a UINavigationController and you may want to wrap this inside of your own UINavigationController before presentation
    ///
    /// - Returns: The viewcontroller to present in your UI.
    public func generateViewController() -> UIViewController {
        let podBundle = Bundle(for: type(of:self))
        let URL = podBundle.url(forResource: "MDTestAccountManager", withExtension: "bundle")!
        let resourceBundle = Bundle(url: URL)
        let controller = UIStoryboard(name: EnvironmentManager.StoryboardName, bundle: resourceBundle).instantiateInitialViewController() as! EnvironmentManagerViewController
        controller.environmentManager = self
        return controller
    }
}

class EnvironmentManagerViewController: UITableViewController {
    private struct CellIdentifiers {
        let APICellIdentifier = "APICellIdentifier"
    }
    
    var environmentManager: EnvironmentManager!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.environmentManager.apiNames().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "APICellIdentifier")!
        let allNames = self.environmentManager.apiNames()
        
        cell.textLabel?.text = allNames[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // Segue in to sub controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}


public class EnvironmentManagerSegue: UIStoryboardSegue {
    public func pass(environmentManager: EnvironmentManager) {
        let destination = self.destination as! UINavigationController
        destination.pass(environmentManager: environmentManager)
    }
}

extension UINavigationController {
    func pass(environmentManager:EnvironmentManager) {
        guard let environmentController = self.viewControllers.first as? EnvironmentManagerViewController else {
            return
        }
        
        environmentController.environmentManager = environmentManager
    }

}
// EnvironmentSelectionViewController
