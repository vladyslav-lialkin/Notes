//
//  TableViewController.swift
//  Notes
//
//  Created by Влад Лялькін on 06.10.2023.
//

import UIKit

class ResultTableViewController: UITableViewController {
    
    private var notes = [Note]()
    private var foundNotes = [Note]()
    private var searchString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: "NoteCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notes = ManagerCoreData.shared.fetchNotes().sorted { $0.dateEdited! > $1.dateEdited! }
        tableView.reloadData()
        print(notes.count)
    }
    
    func searchForNotes(_ text: String) {
        searchString = text
        foundNotes = notes.filter { note in
            let noteText = convertToString(note).lowercased()
            return noteText.contains(text.lowercased())
        }
        tableView.reloadData()
    }
    
    func convertToString(_ note: Note) -> String {
        if let data = note.text,
           let attributedText = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
            return attributedText.string
        }
        return ""
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView")! as! SectionHeaderView
        let count = String(foundNotes.count)
        headerView.titleLabel.text = "Notes"
        headerView.secondLabel.text = (count != "0" ? count : "None") + " Found"
        return headerView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundNotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteTableViewCell

        let text = convertToString(foundNotes[indexPath.row])

        let lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

        if !lines.first!.replacingOccurrences(of: " ", with: "").isEmpty {
            cell.header.text = lines[0]
            var remainingText = lines.dropFirst().filter { !$0.isEmpty }
            if remainingText.isEmpty {
                remainingText = ["No additional text"]
            }
            cell.text.text = remainingText.joined(separator: "\n")
            let headerAttributedText = NSMutableAttributedString(string: cell.header.text!)
            let textAttributedText = NSMutableAttributedString(string: cell.text.text!)

            if !searchString.isEmpty {
                let firstRange = (cell.header.text! as NSString).range(of: searchString, options: .caseInsensitive)
                headerAttributedText.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: firstRange)
                
                let secondRange = (cell.text.text! as NSString).range(of: searchString, options: .caseInsensitive)
                textAttributedText.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: secondRange)
            }
            
            cell.header.attributedText = headerAttributedText
            cell.text.attributedText = textAttributedText
        } else {
            cell.header.attributedText = NSAttributedString(string: "New Note")
            cell.text.attributedText =  NSAttributedString(string: "No additional text")
        }
        
        let combinedText = NSMutableAttributedString()
        combinedText.append(NSAttributedString(string: Sort.date(date: foundNotes[indexPath.row].dateEdited!)))
        combinedText.append(NSAttributedString(string: " "))
        combinedText.append(cell.text.attributedText!)

        cell.text.attributedText = combinedText
        return cell
    }
}

extension ResultTableViewController {
    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let nextViewController = NoteViewController(objectID: foundNotes[indexPath.row].objectID)
        nextViewController.hidesBottomBarWhenPushed = true
        show(nextViewController, sender: self)
    }
}
