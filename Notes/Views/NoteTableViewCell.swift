//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by Влад Лялькін on 12.09.2023.
//

import UIKit


class NoteTableViewCell: UITableViewCell {
    
    let header: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return label
    }()
    
    let text: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = .systemFont(ofSize: 15)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(header)
        addSubview(text)
        header.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            header.bottomAnchor.constraint(equalTo: text.topAnchor, constant: -3),
            
            text.topAnchor.constraint(equalTo: header.bottomAnchor),
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            text.trailingAnchor.constraint(equalTo: trailingAnchor),
            text.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
