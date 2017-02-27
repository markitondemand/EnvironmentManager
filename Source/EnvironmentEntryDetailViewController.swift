//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

/// This viewcontroller shows a selectable list of environments for a specific API entry
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
        self.entry.selectEnvironment(forIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
