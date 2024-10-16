//
//  ImageTableViewCell.swift
//  FileManager
//
//  Created by Роман Лешин on 16.10.2024.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    private lazy var customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(customImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            customImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            customImageView.widthAnchor.constraint(equalToConstant: 80),
            customImageView.heightAnchor.constraint(equalToConstant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: customImageView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(imageModel: ImageModel) {
        customImageView.image = imageModel.image
        titleLabel.text = imageModel.fileName
    }
}
