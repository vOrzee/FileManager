//
//  FileViewModel.swift
//  FileManager
//
//  Created by Роман Лешин on 16.10.2024.
//

import Foundation
import UIKit

class FileViewModel {
    
    var images:[ImageModel] = [] {
        didSet {
            onDataChanged?()
        }
    }
    
    var onDataChanged: (()->Void)?
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func loadImages() {
        do {
            let filesUrls = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            let imagesUrls = filesUrls.filter {$0.pathExtension == "jpg"}
            images.removeAll()
            for imageUrl in imagesUrls {
                guard let imageData = try? Data(contentsOf: imageUrl) else {continue}
                guard let image = UIImage(data: imageData) else {continue}
                images.append(ImageModel(image: image, fileName: imageUrl.lastPathComponent))
            }
        } catch {
            print("Ошибка при загрузке файлов")
        }
    }
    
    func saveImage(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 1.0)
        let fileName = UUID().uuidString + ".jpg"
        let fileUrl = documentsPath.appendingPathComponent(fileName)
        if FileManager.default.createFile(atPath: fileUrl.path, contents: imageData, attributes: nil) {
            print("Изображение успешно сохранено: \(fileUrl)")
        } else {
            print("Ошибка при создании файла.")
        }
        loadImages()
    }
    
    func deleteImage(fileName: String) {
        let fileUrl = documentsPath.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileUrl)
            print("Изображение удалено: \(fileUrl)")
            loadImages()
        } catch {
            print("Ошибка при удалении изображения: \(error)")
        }
    }
}
