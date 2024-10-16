//
//  PasswordViewController.swift
//  FileManager
//
//  Created by Роман Лешин on 17.10.2024.
//

import UIKit
import KeychainSwift

class PasswordViewController: UIViewController {

    let keyChain = KeychainSwift()
    var firstAttemptEntryNewPassValue = ""

    private lazy var passTextField = {
        let textField = UITextField(frame: CGRect(x: 36, y: (UIScreen.main.bounds.height / 3) - 104, width: UIScreen.main.bounds.width - 72, height: 48))
        textField.placeholder = "Новый пароль"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .systemGray6
        textField.textColor = .black
        textField.layer.cornerRadius = 8
        return textField
    }()

    private lazy var repeatPassTextField = {
        let textField = UITextField(frame: CGRect(x: 36, y: (UIScreen.main.bounds.height / 3) - 48, width: UIScreen.main.bounds.width - 72, height: 48))
        textField.placeholder = "Повторите ввод"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .systemGray6
        textField.textColor = .black
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private lazy var saveButton = {
        let button = UIButton(frame: CGRect(x: 36, y: (UIScreen.main.bounds.height / 3) + 8, width: UIScreen.main.bounds.width - 72, height: 48))
        button.setTitle("Сохранить пароль", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        view.addSubview(passTextField)
        view.addSubview(repeatPassTextField)
        view.addSubview(saveButton)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTapButton() {
        let entryPass = passTextField.text
        let repeatEntryPass = repeatPassTextField.text
        passTextField.text = ""
        repeatPassTextField.text = ""
        guard let entryPass, let repeatEntryPass, entryPass.count >= 4 else {
            showAlert(message: "Пароль должен состоять не менее чем из 4 символов")
            return
        }
        if entryPass == repeatEntryPass {
            keyChain.set(entryPass, forKey: "password")
            dismiss(animated: true, completion: nil)
        } else {
            showAlert(message: "Пароли не совпадают")
        }
    }
    
    func showAlert(title: String = "Ошибка", message: String, titleAction: String = "ОК") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: titleAction, style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

