//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

/// This viewcontroller shows a selectable list of environments for a specific API entry
class EnvironmentEntryDetailViewController: UITableViewController {
    private enum CellIdentifiers {
        static let EnvironmentCellIdentifier = "EnvironmentCellIdentifier"
    }
    
    private enum Segue: String {
        case add = "AddSegue"
    }
    
    var entryName: String!
    var viewModel: EntryViewModel!
    
    
    override func viewDidLoad() {
        self.navigationItem.title = self.entryName
        viewModel = EntryViewModel(entry: currentEntry, customStore: EnvironmentManagerViewcontroller.sharedEnvironmentManager.customEntryStore)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = Segue(rawValue: segue.identifier ?? "") else {
            return
        }
        
        switch segueID {
        case .add:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentEntry.environmentNames().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.EnvironmentCellIdentifier)!
        let sortedEnvironmentNames = self.currentEntry.environmentNames()
        cell.textLabel?.text = sortedEnvironmentNames[indexPath.row]
        cell.accessoryType = self.currentEntry.currentEnvironment == sortedEnvironmentNames[indexPath.row] ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentEntry.selectEnvironment(forIndex: indexPath.row)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
    private var currentEntry: Entry {
        return EnvironmentManagerViewcontroller.sharedEnvironmentManager.entry(forService: entryName)!
    }
}



// MARK: - Segue
extension EnvironmentEntryDetailViewController {
    @IBAction func addEnvironment(_ segue: UIStoryboardSegue) {
        guard let destination = segue.destination as? AddEnvironmentViewController else {
            return
        }
        guard let newEnvironment = destination.newEnvironment else {
            return
        }
        self.viewModel.addEnvironment(Entry.Environment(pair: newEnvironment))
    }
}


class EntryViewModel {
    var baseEntry: Entry
    var customEntryStore: CustomEntryStore
    
    var name: String {
        return baseEntry.name
    }
    
    var baseEnviromnments: [Entry.Environment] {
        return self.baseEntry.environments
    }
    
    var customEnvironments: [Entry.Environment] {
        return self.customEntryStore[name]?.environments ?? []
    }
    
    init(entry: Entry, customStore: CustomEntryStore) {
        baseEntry = entry
        customEntryStore = customStore
    }
    
    
    // Mutators
    func addEnvironment(_ environment: Entry.Environment) {
        let entry = self.customEntryStore[name]
        entry?.add((environment.environment, environment.baseUrl))
        self.customEntryStore[name] = entry
    }
    
    func removeEnvironment(_ environmentName: String) {
        let entry = self.customEntryStore[name]
        entry?.removeEnvironment(environmentName)
        self.customEntryStore[name] = entry
    }
}
