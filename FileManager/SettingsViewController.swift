//
//  SettingsViewController.swift
//  FileManager
//
//  Created by Роман Лешин on 17.10.2024.
//
import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Сортировка"
            let sortSwitch = UISwitch()
            sortSwitch.isOn = FileViewModel.shared.withSorting
            sortSwitch.addTarget(self, action: #selector(toggleSortOrder(_:)), for: .valueChanged)
            cell.accessoryView = sortSwitch
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Поменять пароль"
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let passwordVC = PasswordViewController()
            let navController = UINavigationController(rootViewController: passwordVC)
            present(navController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == 0, FileViewModel.shared.withSorting {
            let alphabeticalAction = UIContextualAction(style: .normal, title: "Алфавитный") { (action, view, completionHandler) in
                FileViewModel.shared.setSortingStrategy(sortingStrategy: .alphabetical)
                completionHandler(true)
            }
            alphabeticalAction.backgroundColor = .blue
            
            let reverseAction = UIContextualAction(style: .normal, title: "Обратный") { (action, view, completionHandler) in
                FileViewModel.shared.setSortingStrategy(sortingStrategy: .reversive)
                completionHandler(true)
            }
            reverseAction.backgroundColor = .orange
            
            let configuration = UISwipeActionsConfiguration(actions: [alphabeticalAction, reverseAction])
            return configuration
        }
        return nil
    }
    
    @objc func toggleSortOrder(_ sender: UISwitch) {
        if sender.isOn {
            FileViewModel.shared.applySorting()
        } else {
            FileViewModel.shared.refuseSorting()
        }
    }
}

