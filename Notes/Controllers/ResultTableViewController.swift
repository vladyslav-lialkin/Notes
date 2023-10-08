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
                
        cell.header.text = text != "" ? text : "New Note"
        cell.text.text = Sort.date(date: foundNotes[indexPath.row].dateEdited!) + " " + (text != "" ? text : "No additional text")
        return cell
    }
}
