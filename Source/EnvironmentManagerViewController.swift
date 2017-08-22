//  Copyright © 2017 Markit. All rights reserved.
//

import UIKit


/// Needed to work around an issue with cocoapods where they dont let you set your own bundle identifier
class BundleAccessor {
    var resourceBundle: Bundle {
        let frameworkBundle = Bundle(for: type(of: self))
        
        // Note - If the app is installed via cocoapods our resources are in a separate resource bundle, but if it is installed another way (i.e. dragging source) then the resources are not in a separate "resource bundle" and are instead in the framework bundle.
        // TODO: it may be possible to change how the project builds, so that it generate a framework with the given resource bundle name so that tests and what not work properly.
        guard let resourceBundleURL = frameworkBundle.url(forResource: "MDEnvironmentManager", withExtension: "bundle") else {
            return frameworkBundle
        }
        guard let bundle = Bundle(url: resourceBundleURL) else {
            return frameworkBundle
        }
        return bundle
    }
}

/// This class manages a default UI for selecting environments
class EnvironmentManagerViewcontroller: UITableViewController {
    internal static var sharedEnvironmentManager: EnvironmentManager!
    
    private enum Segue: String {
        case Exit = "Exit"
        case EnvironmentDetails = "EnvironmentDetails"
    }
    
    private enum CellIdentifiers {
        static let APICellIdentifier = "APICellIdentifier"
        static let AddCellIdentifier = "AddEnvironmentIdentifier"
    }
    
    var environmentManager: EnvironmentManager {
        get {
            return EnvironmentManagerViewcontroller.sharedEnvironmentManager
        }
        set(value) {
            EnvironmentManagerViewcontroller.sharedEnvironmentManager = value
        }
    }
    
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
        guard let segueID = Segue(rawValue: segue.identifier ?? "") else {
            return
        }
        
        switch segueID {
        case .EnvironmentDetails:
            guard let controller = segue.destination as? EnvironmentEntryDetailViewController else {
                return
            }
            
            guard let cell = sender as? UITableViewCell else {
                return
            }
            
            let index = self.tableView.indexPath(for: cell)!.row
            controller.entryName = self.environmentManager.entry(forIndex: index)?.name
        case .Exit:
            return
//            self.environmentManager.save()
        }
    }
}

// MARK: - Data Passing Between controller and storyboards
extension UIViewController {
    
    /// Helper method used for passing the EnvironmentManager into our segue.
    ///
    /// - Parameter environmentManager: The manager to pass
    public func pass(_ environmentManager: EnvironmentManager) {
        guard let controller = self as? EnvironmentManagerPassable else {
            return
        }
        controller.pass(environmentManager: environmentManager)
    }
}

/// Protocol that defines the entry point for passing a pre created EnvironmentManager to the UI
protocol EnvironmentManagerPassable {
    func pass(environmentManager: EnvironmentManager)
}

extension EnvironmentManagerViewcontroller: EnvironmentManagerPassable {
    func pass(environmentManager: EnvironmentManager) {
        self.environmentManager = environmentManager
    }
}

extension UINavigationController: EnvironmentManagerPassable {
    func pass(environmentManager:EnvironmentManager) {
        guard let environmentController = self.viewControllers.first as? EnvironmentManagerPassable else {
            return
        }
        environmentController.pass(environmentManager: environmentManager)
    }
}
