//  Copyright © 2017 Markit. All rights reserved.
//

import UIKit


extension EnvironmentManager {
    // Name of the storyboard
    public static let StoryboardName = "EnvironmentManagerStoryboard"
}

protocol EnvironmentManagerController {
    func pass(environmentManager: EnvironmentManager)
}

class EnvironmentManagerViewController: UITableViewController, EnvironmentManagerController {
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
        controller.entry = self.environmentManager.entryFor(index: index)
    }
    
    //TOOD: use exit segue
    @IBAction func doneTapped(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}


//TOOD: move to separate class
/// This viewcontroller shows a selctable list of environments for a specific API entry
class EnvironmentEntryDetailViewController: UITableViewController {
    private struct CellIdentifiers {
        static let EnvironmentCellIdentifier = "EnvironmentCellIdentifier"
    }
   
    var entry: Entry!
    
    override func viewDidLoad() {
        self.navigationItem.title = self.entry.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entry.environmentNames().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.EnvironmentCellIdentifier)!
        cell.textLabel?.text = self.entry.environmentNames()[indexPath.row]
        cell.accessoryType = self.entry.currentEnvironment == self.entry.environmentNames()[indexPath.row] ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.entry.selectEnvironment(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
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
