//
//  FileViewModel.swift
//  FileManager
//
//  Created by Роман Лешин on 16.10.2024.
//

import Foundation
import UIKit

class FileViewModel {
    
    static let shared = FileViewModel()
    
    var images:[ImageModel] = [] {
        didSet {
            onDataChanged?()
        }
    }
    
    var onDataChanged: (()->Void)?
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private(set) var withSorting: Bool {
        didSet {
            if withSorting {
                sortImages()
            }
            UserDefaults.standard.set(withSorting, forKey: "withSorting")
        }
    }
    
    private var sortingStrategy: SortingStrategy {
        didSet {
            sortImages()
            UserDefaults.standard.set(sortingStrategy.rawValue, forKey: "sortingStrategy")
        }
    }
    
    private init() {
        if UserDefaults.standard.object(forKey: "withSorting") == nil {
            UserDefaults.standard.set(true, forKey: "withSorting")
        }
        if UserDefaults.standard.object(forKey: "sortingStrategy") == nil {
            UserDefaults.standard.set("alphabetical", forKey: "sortingStrategy")
        }
        withSorting = UserDefaults.standard.bool(forKey: "withSorting")
        sortingStrategy = SortingStrategy(rawValue: UserDefaults.standard.string(forKey: "sortingStrategy") ?? "") ?? .alphabetical
    }
    
    func sortImages() {
        switch sortingStrategy {
        case .alphabetical:
            images.sort(by: {$0.fileName.lowercased() < $1.fileName.lowercased()})
        case .reversive:
            images.sort(by: {$0.fileName.lowercased() > $1.fileName.lowercased()})
        }
    }
    
    func refuseSorting() { withSorting = false }
    func applySorting() { withSorting = true }
    func setSortingStrategy(sortingStrategy: SortingStrategy) {
        self.sortingStrategy = sortingStrategy
    }
    
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
            if withSorting { sortImages() }
        } catch {
            print("Ошибка при загрузке файлов")
        }
    }
    
    func saveImage(image: UIImage, name: String = "") {
        let imageData = image.jpegData(compressionQuality: 1.0)
        var fileName = name
        if fileName.isEmpty {
            fileName = UUID().uuidString
        }
        let fileUrl = documentsPath.appendingPathComponent(fileName + ".jpg")
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
