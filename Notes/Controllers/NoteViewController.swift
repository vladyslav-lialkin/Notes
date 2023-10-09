//
//  NoteViewController.swift
//  Notes
//
//  Created by Влад Лялькін on 12.09.2023.
//

import UIKit
import CoreData


class NoteViewController: UIViewController {
    
    private var objectID: NSManagedObjectID!

    private let attributedScrollView = UIScrollView()
    
    private let attributedTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.tintColor = UIColor.systemYellow
        let font = UIFont.systemFont(ofSize: 27, weight: .bold)
        let textColor = UIColor.label
        let attributes: [NSAttributedString.Key: Any] = [.font: font as Any, .foregroundColor: textColor]
        let attributedString = NSAttributedString(string: " ", attributes: attributes)
        textView.attributedText = attributedString
        textView.isScrollEnabled = false
        return textView
    }()
    
    private var formatScrollView: FormatScrollView!
    
    private var previewSRL: Int! //preview selectedRange.location
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemBackground
        
        navigationItem.largeTitleDisplayMode = .never
                
        attributedScrollView.translatesAutoresizingMaskIntoConstraints = false
        attributedScrollView.keyboardDismissMode = .interactive
        attributedScrollView.alwaysBounceVertical = true
        view.addSubview(attributedScrollView)
                
        attributedTextView.delegate = self
        attributedScrollView.addSubview(attributedTextView)
        
        formatScrollView = FormatScrollView(self)
        formatScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(formatScrollView)
        
        NSLayoutConstraint.activate([
            attributedScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            attributedScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            attributedScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            attributedScrollView.bottomAnchor.constraint(equalTo: formatScrollView.topAnchor),

            attributedTextView.topAnchor.constraint(equalTo: attributedScrollView.topAnchor, constant: 20),
            attributedTextView.leadingAnchor.constraint(equalTo: attributedScrollView.leadingAnchor, constant: 20),
            attributedTextView.trailingAnchor.constraint(equalTo: attributedScrollView.trailingAnchor, constant: -20),
            attributedTextView.bottomAnchor.constraint(equalTo: attributedScrollView.bottomAnchor, constant: -20),
            attributedTextView.widthAnchor.constraint(equalTo: attributedScrollView.widthAnchor, constant: -40),
            
            formatScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            formatScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            formatScrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            formatScrollView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if attributedTextView.text.isEmpty {
            attributedTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        attributedTextView.resignFirstResponder()
        if attributedTextView.attributedText != loadAttributedTextFromCoreData() {
            ManagerCoreData.shared.updataNote(with: objectID, attributedText: attributedTextView.attributedText)
        }
    }
    
    func setFont(_ font: UIFont) {
        let selectedRange = attributedTextView.selectedRange
        
        let text = attributedTextView.text as NSString
        
        let cursorIndex = selectedRange.location
        
        var lineStart = cursorIndex
        var lineEnd = cursorIndex
        
        while lineStart > 0 && text.character(at: lineStart - 1) != 10 {
            lineStart -= 1
        }
        
        while lineEnd < text.length && text.character(at: lineEnd) != 10 {
            lineEnd += 1
        }
        
        if (lineEnd - lineStart) != 0 {
            let lineRange = NSRange(location: lineStart, length: lineEnd - lineStart)
            
            
            var currentAttributes = attributedTextView.textStorage.attributes(at: lineRange.location, effectiveRange: nil)
                    
            currentAttributes[.font] = font as Any
                    
            attributedTextView.textStorage.addAttributes(currentAttributes, range: lineRange)
        }
        attributedTextView.typingAttributes[.font] = font
    }

    
    init(objectID: NSManagedObjectID){
        super.init(nibName: nil, bundle: nil)
        
        self.objectID = objectID
        self.attributedTextView.attributedText = loadAttributedTextFromCoreData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadAttributedTextFromCoreData() -> NSAttributedString? {
        if let data = ManagerCoreData.shared.fetchNote(with: objectID)?.text,
            let attributedText = try? NSKeyedUnarchiver.unarchivedObject(ofClass:NSAttributedString.self, from: data) {
            return attributedText
        }

        return nil
    }
}

extension NoteViewController: UITextViewDelegate {
    
    //MARK: UITextViewDelegate
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let cursorPosition = textView.selectedRange.location
        
        if previewSRL != cursorPosition {
            previewSRL = cursorPosition
            let textStorage = textView.textStorage

            var lineStart = cursorPosition
            var lineEnd = cursorPosition

            let text = textStorage.string as NSString

            while lineStart > 0 && text.character(at: lineStart - 1) != 10 {
                lineStart -= 1
            }

            while lineEnd < text.length && text.character(at: lineEnd) != 10 {
                lineEnd += 1
            }

            if (lineEnd - lineStart) != 0 {
                let lineRange = NSRange(location: lineStart, length: lineEnd - lineStart)

                let attributes = textStorage.attributes(at: lineRange.location, effectiveRange: nil)

                if let font = attributes[.font] as? UIFont {
                    if let rect = formatScrollView.setFormat(fontName: font.fontName) {
                        // Отримайте позицію для прокрутки
                        let scrollPoint = CGPoint(x: rect.midX - formatScrollView.bounds.width / 2, y: 0)

                        // Обмежте scrollPoint, щоб уникнути виходу за межі контенту
                        let maxOffsetX = formatScrollView.contentSize.width - formatScrollView.bounds.width
                        let clampedX = max(0, min(scrollPoint.x, maxOffsetX))
                        
                        // Прокручайте formatScrollView до позиції
                        formatScrollView.setContentOffset(CGPoint(x: clampedX, y: 0), animated: true)
                    }
                }
            }
        }
        previewSRL += 1
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            attributedTextView.typingAttributes[.font] = UIFont.systemFont(ofSize: 18)
            formatScrollView.setFormat(fontName: UIFont.systemFont(ofSize: 18).fontName)
            return true
        }
        return true
    }
}
