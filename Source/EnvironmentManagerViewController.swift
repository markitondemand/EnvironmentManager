//  Copyright © 2017 Markit. All rights reserved.
//

import UIKit



extension UIStoryboard {
    /// The name of the storyboard this belong to
    public static let StoryboardName = "EnvironmentManagerStoryboard"
}

/// Custom segue used to pass the Environment manager into the view controller via a Storyboard Segue
public class EnvironmentManagerSegue: UIStoryboardSegue {
    public func pass(environmentManager: EnvironmentManager) {
        guard let destination = self.destination as? EntryEnvironmentManagerController else {
            return
        }
        destination.pass(environmentManager: environmentManager)
    }
}


/// Protocol that defines the entry point for passing a pre created EnvironmentManager to the UI
protocol EntryEnvironmentManagerController {
    func pass(environmentManager: EnvironmentManager)
}

/// This class manages a default UI for selecting environment
class EnvironmentManagerViewController: UITableViewController, EntryEnvironmentManagerController {
    private struct CellIdentifiers {
        let APICellIdentifier = "APICellIdentifier"
    }
    
    var environmentManager: EnvironmentManager!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.environmentManager.apiNames().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "APICellIdentifier")!
        
        let apiName = self.environmentManager.apiNames()[indexPath.row]
        cell.textLabel?.text = apiName
        cell.detailTextLabel?.text = self.environmentManager.currentEnvironmentFor(apiName: apiName)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func pass(environmentManager: EnvironmentManager) {
        self.environmentManager = environmentManager
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? EnvironmentEntryDetailViewController else {
            return
        }
        
        guard let cell = sender as? UITableViewCell else {
            return
        }
        
        let index = self.tableView.indexPath(for: cell)!.row
        controller.entry = self.environmentManager.entry(forIndex: index)
    }
}


/// Implement this protocol method somewhere in your application where you presented this UI from to allow the environment manager to unwind. This function will be called when the presented viewcontroller unwinds
public protocol Unwindable {
    func unwind(toExit segue:UIStoryboardSegue)
}

extension UINavigationController: EntryEnvironmentManagerController {
    func pass(environmentManager:EnvironmentManager) {
        guard let environmentController = self.viewControllers.first as? EnvironmentManagerViewController else {
            return
        }
        environmentController.environmentManager = environmentManager
    }
}
