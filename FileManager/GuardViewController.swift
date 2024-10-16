//
//  GuardViewController.swift
//  FileManager
//
//  Created by Роман Лешин on 16.10.2024.
//

import UIKit
import KeychainSwift

class GuardViewController: UIViewController {
    
    let keyChain = KeychainSwift()
    var isFirstEntry: Bool {
        !keyChain.allKeys.contains("password")
    }
    var firstAttemptEntryNewPassValue = ""

    private lazy var passTextField = {
        let textField = UITextField(frame: CGRect(x: 36, y: (UIScreen.main.bounds.height / 2) - 48, width: UIScreen.main.bounds.width - 72, height: 48))
        textField.placeholder = "Пароль"
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 8
        textField.isSecureTextEntry = true
        textField.textColor = .black
        return textField
    }()
    
    private lazy var entryButton = {
        let button = UIButton(frame: CGRect(x: 36, y: (UIScreen.main.bounds.height / 2) + 8, width: UIScreen.main.bounds.width - 72, height: 48))
        button.setTitle(isFirstEntry ? "Создать пароль" : "Введите пароль", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        view.addSubview(passTextField)
        view.addSubview(entryButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func onTapButton() {
        guard let entryPass = passTextField.text, entryPass.count >= 4 else {
            showAlert(message: "Пароль должен состоять не менее чем из 4 символов")
            passTextField.text = ""
            return
        }
        if isFirstEntry {
            if firstAttemptEntryNewPassValue.isEmpty {
                firstAttemptEntryNewPassValue = entryPass
                passTextField.text = ""
                entryButton.setTitle("Повторите пароль", for: .normal)
            } else {
                passTextField.text = ""
                guard entryPass == firstAttemptEntryNewPassValue else {
                    firstAttemptEntryNewPassValue = ""
                    entryButton.setTitle("Создать пароль", for: .normal)
                    showAlert(message: "Пароли не совпадают")
                    return
                }
                keyChain.set(entryPass, forKey: "password")
                entryButton.setTitle("Ввести пароль", for: .normal)
                showTabBarController()
            }
        } else {
            guard let pass = keyChain.get("password") else {return}
            if pass == passTextField.text {
                showTabBarController()
            } else {
                passTextField.text = ""
                showAlert(message: "Вы ввели неверный пароль")
            }
        }
    }
    
    func showAlert(title: String = "Ошибка", message: String, titleAction: String = "ОК") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: titleAction, style: .cancel))
        present(alert, animated: true)
    }
    
    func showTabBarController() {
        let fileVC = FileViewController()
        fileVC.tabBarItem = UITabBarItem(title: "Файлы", image: UIImage(systemName: "folder"), tag: 1)
        let fileNavController = UINavigationController(rootViewController: fileVC)
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gearshape"), tag: 0)
        let settingsNavController = UINavigationController(rootViewController: settingsVC)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [settingsNavController, fileNavController]
        
        tabBarController.selectedIndex = 1
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(tabBarController, animated: true)
    }
}

