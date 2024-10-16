//
//  FileViewControlerViewController.swift
//  FileManager
//
//  Created by Роман Лешин on 16.10.2024.
//

import UIKit

class FileViewController: UIViewController {
    
    private let viewModel = FileViewModel.shared
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray4
        
        title = "Изображения"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .done, target: self, action: #selector(addPhoto))
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "ImageCell")
        
        viewModel.loadImages()
        viewModel.onDataChanged = { [weak self] in
            guard let self else {return}
            tableView.reloadData()
        }
    }
    

    @objc func addPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    func showFullScreenImage(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.frame = self.view.bounds
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreenImage))
        imageView.addGestureRecognizer(tapGesture)
        imageView.tag = 601
        self.view.addSubview(imageView)
        self.navigationController?.isNavigationBarHidden = true
    }

    @objc func dismissFullScreenImage() {
        if let image = view.viewWithTag(601) {
            image.removeFromSuperview()
        }
        self.navigationController?.isNavigationBarHidden = false
    }

}

extension FileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageTableViewCell else { fatalError("could not dequeueReusableCell") }
        
        cell.bind(imageModel: viewModel.images[indexPath.row])
        
        return cell
    }
}

extension FileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            guard let self else {return}
            let fileName = viewModel.images[indexPath.row].fileName
            viewModel.deleteImage(fileName: fileName)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: "Переименовать") { [weak self] (action, view, completionHandler) in
            guard let self else {return}
            let oldFileName = viewModel.images[indexPath.row].fileName
            let image = viewModel.images[indexPath.row].image
            
            let alert = UIAlertController(title: "Переименовать изображение", message: "Введите имя для файла", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Имя файла"
            }

            let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
                guard let self else {return}
                guard let fileName = alert.textFields?.first?.text, !fileName.isEmpty else {
                    viewModel.deleteImage(fileName: oldFileName)
                    viewModel.saveImage(image: image)
                    return
                }
                viewModel.deleteImage(fileName: oldFileName)
                viewModel.saveImage(image: image, name: fileName)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)

            present(alert, animated: true, completion: nil)
            
            
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [renameAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let image = viewModel.images[indexPath.row].image
        showFullScreenImage(image: image)
    }
}

extension FileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            let alert = UIAlertController(title: "Сохранить изображение", message: "Введите имя для файла", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Имя файла"
            }

            let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
                guard let self else {return}
                guard let fileName = alert.textFields?.first?.text, !fileName.isEmpty else {
                    viewModel.saveImage(image: image)
                    return
                }
                viewModel.saveImage(image: image, name: fileName)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)

            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension FileViewController: UINavigationControllerDelegate {}
