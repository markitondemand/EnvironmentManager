//  Copyright © 2017 Markit. All rights reserved.
//

import UIKit

extension UIStoryboard {
    /// The name of the storyboard this belong to. you can segue to a Storyboad using this identifier
    public static let EnvironmentManagerStoryboardName = "EnvironmentManagerStoryboard"
}

class EnvironmentManagerViewcontroller: UITableViewController {

/// This class manages a default UI for selecting environment
    private enum SegueIdentifiers {
        static let Exit = "Exit"
        static let EnvironmentDetails = "EnvironmentDetails"
    }
    private enum CellIdentifiers {
        static let APICellIdentifier = "APICellIdentifier"
    }
    
    var environmentManager: EnvironmentManager!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.environmentManager.apiNames().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.APICellIdentifier)!
        
        let apiName = self.environmentManager.apiNames()[indexPath.row]
        cell.textLabel?.text = apiName
        cell.detailTextLabel?.text = self.environmentManager.currentEnvironmentFor(apiName: apiName)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case SegueIdentifiers.EnvironmentDetails:
            guard let controller = segue.destination as? EnvironmentEntryDetailViewController else {
                return
            }
            
            guard let cell = sender as? UITableViewCell else {
                return
            }
            
            let index = self.tableView.indexPath(for: cell)!.row
            controller.entry = self.environmentManager.entry(forIndex: index)
        case SegueIdentifiers.Exit:
            self.environmentManager.save(usingStore: UserDefaultsStore())
        default:
            return
        }

    }
}

/// Implement this protocol method somewhere in your application where you presented this UI from to allow the environment manager to unwind. This function will be called when the presented viewcontroller unwinds
public protocol Unwindable {
    func unwind(toExit segue:UIStoryboardSegue)
}

/// Custom segue used to pass the Environment manager into the view controller via a Storyboard Segue. This is passed into your prepareForSegue:sender: method. You should use this to pass your environment maanager into the UI
public class EnvironmentManagerSegue: UIStoryboardSegue {
    public func pass(environmentManager: EnvironmentManager) {
        guard let destination = self.destination as? ManagerPassable else {
            return
        }
        destination.pass(environmentManager: environmentManager)
    }
}

extension EnvironmentManagerViewcontroller: ManagerPassable {
    func pass(environmentManager: EnvironmentManager) {
        self.environmentManager = environmentManager
    }
}


/// Protocol that defines the entry point for passing a pre created EnvironmentManager to the UI
protocol ManagerPassable {
    func pass(environmentManager: EnvironmentManager)
}

extension UINavigationController: ManagerPassable {
    func pass(environmentManager:EnvironmentManager) {
        guard let environmentController = self.viewControllers.first as? ManagerPassable else {
            return
        }
        environmentController.pass(environmentManager: environmentManager)
    }
}
