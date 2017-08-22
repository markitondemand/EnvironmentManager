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
//        viewModel = EntryViewModel(entry: currentEntry, customStore: EnvironmentManagerViewcontroller.sharedEnvironmentManager.customEntryStore)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.customEnvironments.count > 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.baseEnviromnments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.EnvironmentCellIdentifier)!

        let environment: Entry.Environment
        if indexPath.section == 1 {
            environment = viewModel.baseEnviromnments[indexPath.row]
        }
        else {
            environment = viewModel.customEnvironments[indexPath.row]
        }
        
//        let sortedEnvironmentNames = self.viewModel.baseEnviromnments
        cell.textLabel?.text = environment.environment
//        cell.accessoryType = self.currentEntry.currentEnvironment == sortedEnvironmentNames[indexPath.row] ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectEnvironment(indexPath.row)
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
    
    private var allEnvironments: [Entry.Environment] {
        return baseEnviromnments + customEnvironments
    }
    
    
    // Mutators
    func addEnvironment(_ environment: Entry.Environment) {
        var entry = self.customEntryStore[name]
        entry?.add((environment.environment, environment.baseUrl))
        self.customEntryStore[name] = entry
    }
    
    func removeEnvironment(_ environmentName: String) {
        var entry = self.customEntryStore[name]
        entry?.removeEnvironment(environmentName)
        self.customEntryStore[name] = entry
    }
    
    func selectEnvironment(_ index: Int) {
        
    }
    
//    var selectedEnvironment: String {
//        
//    }
//    func selectedEnvironment(for indexPath: IndexPath) -> Bool {
//        if indexPath.section == 1 {
//            let environment = self.baseEnviromnments[indexPath.row]
//            
//        }
//        else {
//            
//        }
//    }
}
