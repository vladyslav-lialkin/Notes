//
//  NotesViewController.swift
//  Notes
//
//  Created by Влад Лялькін on 11.09.2023.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: ResultTableViewController())
    
    private var tableView: UITableView!

    private var sections = [Section]()
    
    private var sort: SortBy {
        get {
            if let storedSortRawValue = UserDefaults.standard.value(forKey: "SortBy") as? Int,
               let storedSort = SortBy(rawValue: storedSortRawValue) {
                return storedSort
            }
            return .dateEdited
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "SortBy")
            UserDefaults.standard.synchronize()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - navigation configuration
        
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Notes"

        let addOption = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis.circle"), menu: createMenuForOptions())
        navigationItem.leftBarButtonItem = addOption

        let addNote = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addNoteTapped))
        navigationItem.rightBarButtonItem = addNote
        
        searchController.searchResultsUpdater = self
        searchController.showsSearchResultsController = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        //MARK: - tableView configuration
        
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: "NoteCell")
        view.addSubview(tableView)
        
        //MARK: - tabBar configuration
        
        tabBarController!.tabBar.tintColor = .label
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshNotes()
        showCountNotes()
    }

    private func createMenuForOptions() -> UIMenu {
        let handler: (_ action: UIAction) -> () = { action in
            switch action.identifier.rawValue {
            case "date_edited":
                self.sort = .dateEdited
            case "date_created":
                self.sort = .dateCreated
            case "title":
                self.sort = .title
            default:
                break
            }
            self.refreshNotes()
        }
        
        let actions = [
            UIAction(title: "Date Edite",
                     identifier: UIAction.Identifier("date_edited"),
                     state: (sort == .dateEdited) ? .on : .off,
                     handler: handler),
            UIAction(title: "Date Created", 
                     identifier: UIAction.Identifier("date_created"),
                     state: (sort == .dateCreated) ? .on : .off,
                     handler: handler),
            UIAction(title: "Title", 
                     identifier: UIAction.Identifier("title"),
                     state: (sort == .title) ? .on : .off,
                     handler: handler)
        ]
        
        return UIMenu(title: "Sort By", options: .singleSelection, children: actions)
    }
    
    @objc 
    func addNoteTapped() {
        let objectID = ManagerCoreData.shared.createNote(attributedText: NSAttributedString.init(string: ""))
        let nextViewController = NoteViewController(objectID: objectID!)
        nextViewController.hidesBottomBarWhenPushed = true
        show(nextViewController, sender: self)
    }
    
    private func refreshNotes() {
        let sortedNotes = ManagerCoreData.shared.fetchNotes()
        
        switch sort {
        case .dateEdited:
            sections = Sort.notes(notes: sortedNotes.sorted { $0.dateEdited! > $1.dateEdited! }, sort: .dateEdited)
        case .dateCreated:
            sections = Sort.notes(notes: sortedNotes.sorted { $0.dateCreated! > $1.dateCreated! }, sort: .dateCreated)
        case .title:
            sections = []
            sections.append(Section(title: "Notes", notes: sortedNotes.sorted { convertToString($0) < convertToString($1) }))
        }
        
        tableView.reloadData()
    }
    
    private func showCountNotes() {
        var countString: String!
        let count = ManagerCoreData.shared.fetchNotes().count
        switch count {
        case 2...:
            countString = "\(count) Notes"
        case 1:
            countString = "\(count) Note"
        default:
            countString = "No Notes"
        }
        tabBarController!.tabBar.items?[0].title = countString
    }
    
    func convertToString(_ note: Note) -> String {
        if let data = note.text,
           let attributedText = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
            return attributedText.string
        }
        return ""
    }
}

extension NotesViewController: UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as! SectionHeaderView
        headerView.titleLabel.text = sections[section].title
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteTableViewCell

        let text = convertToString(sections[indexPath.section].notes[indexPath.row])

        let lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

        if !lines.first!.replacingOccurrences(of: " ", with: "").isEmpty {
            cell.header.text = lines[0]
            var remainingText = lines.dropFirst().filter { !$0.isEmpty }
            if remainingText.isEmpty {
                remainingText = ["No additional text"]
            }
            cell.text.text = remainingText.joined(separator: "\n")
        } else {
            cell.header.text = "New Note"
            cell.text.text = "No additional text"
        }

        cell.text.text = Sort.date(date: sections[indexPath.section].notes[indexPath.row].dateEdited!) + " " + cell.text.text!
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .none: break
        case .delete:
            let note = sections[indexPath.section].notes.remove(at: indexPath.row)
            ManagerCoreData.shared.deletaNote(with: note.objectID)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            if sections[indexPath.section].notes.isEmpty{
                sections.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .fade)
            }
            tableView.endUpdates()
            
            showCountNotes()
        case .insert: break
        @unknown default:
            fatalError("Error")
        }
    }

    //MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let nextViewController = NoteViewController(objectID: sections[indexPath.section].notes[indexPath.row].objectID)
        nextViewController.hidesBottomBarWhenPushed = true
        show(nextViewController, sender: self)
    }
    
    //MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, text != " " else {
            return
        }
        
        (searchController.searchResultsController as! ResultTableViewController).searchForNotes(text)
    }
}
