//
//  CustomScrollView.swift
//  Notes
//
//  Created by Влад Лялькін on 20.09.2023.
//

import UIKit

class FormatScrollView: UIScrollView {
    
    //MARK: Format properties
    
    private let formatTitle: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27, weight: .bold)
        button.setTitle("Title", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let formatHeading: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        button.setTitle("Heading", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()

    private let formatSubheading: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.setTitle("Subheading", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let formatBody: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitle("Body", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let formatMonostyled: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Menlo-Regular", size: 18)
        button.setTitle("Monostyled", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    //MARK: Other properties
    
    private let senderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 10
        return view
    }()
    
    private var initialSetupCompleted = false
        
    private weak var noteViewController: NoteViewController?
    
    init(_ noteViewController: NoteViewController) {
        super.init(frame: CGRect.zero)
        
        self.noteViewController = noteViewController
        
        backgroundColor = .systemGray6
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        
        addSubview(senderView)
        
        addSubview(formatTitle)
        addSubview(formatHeading)
        addSubview(formatSubheading)
        addSubview(formatBody)
        addSubview(formatMonostyled)
        
        NSLayoutConstraint.activate([
            formatTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            formatTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            formatTitle.heightAnchor.constraint(equalToConstant: 26),
            
            formatHeading.leadingAnchor.constraint(equalTo: formatTitle.trailingAnchor, constant: 25),
            formatHeading.centerYAnchor.constraint(equalTo: centerYAnchor),
            formatHeading.heightAnchor.constraint(equalToConstant: 26),
            
            formatSubheading.leadingAnchor.constraint(equalTo: formatHeading.trailingAnchor, constant: 25),
            formatSubheading.centerYAnchor.constraint(equalTo: centerYAnchor),
            formatSubheading.heightAnchor.constraint(equalToConstant: 26),
            
            formatBody.leadingAnchor.constraint(equalTo: formatSubheading.trailingAnchor, constant: 25),
            formatBody.centerYAnchor.constraint(equalTo: centerYAnchor),
            formatBody.heightAnchor.constraint(equalToConstant: 26),
            
            formatMonostyled.leadingAnchor.constraint(equalTo: formatBody.trailingAnchor, constant: 25),
            formatMonostyled.centerYAnchor.constraint(equalTo: centerYAnchor),
            formatMonostyled.heightAnchor.constraint(equalToConstant: 26),
            formatMonostyled.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
        ])
        
        for button in [formatTitle, formatHeading, formatSubheading, formatBody, formatMonostyled] {
            button.setTitleColor(.systemGray, for: .highlighted)
            button.addTarget(self, action: #selector(changeFormat(_:)), for: .touchUpInside)
        }
    }
    
    @objc func changeFormat(_ sender: UIButton) {
        moveSenderView(sender)
        noteViewController?.setFont(sender.titleLabel!.font)
    }
    
    func setFormat(fontName: String) -> CGRect! {
        let fontButtonMapping: [String: UIButton] = [
            formatTitle.titleLabel!.font.fontName: formatTitle,
            formatHeading.titleLabel!.font.fontName: formatHeading,
            formatSubheading.titleLabel!.font.fontName: formatSubheading,
            formatBody.titleLabel!.font.fontName: formatBody,
            formatMonostyled.titleLabel!.font.fontName: formatMonostyled
        ]

        if let button = fontButtonMapping[fontName] {
            moveSenderView(button)
            return button.frame
        }
        return nil
    }
    
    func moveSenderView(_ sender: UIButton, duration: TimeInterval! = 0.3) {
        UIView.animate(withDuration: duration, animations: {
            self.senderView.frame.size = CGSize(width: sender.frame.width + 20, height: sender.frame.height + 20)
            self.senderView.center = sender.center
        })
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !initialSetupCompleted {
            initialSetupCompleted = true
                
            moveSenderView(formatTitle, duration: 0.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
