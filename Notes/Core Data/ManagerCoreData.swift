//
//  ManagerCoreData.swift
//  Notes
//
//  Created by Влад Лялькін on 11.09.2023.
//

import UIKit
import CoreData

public final class ManagerCoreData: NSObject {
    public static let shared = ManagerCoreData()
    private override init() {}
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    public func createNote(attributedText: NSAttributedString?) -> NSManagedObjectID?{
        if let attributedText = attributedText {
            do {
                let text = try NSKeyedArchiver.archivedData(withRootObject: attributedText, requiringSecureCoding: false)
                
                let note = Note(context: context)
                note.text = text
                note.dateCreated = Date()
                note.dateEdited = Date()

                // Зберігаємо зміни
                appDelegate.saveContext()
                return note.objectID
            } catch {
                print("Помилка під час архівування та збереження атрибутованого тексту: \(error)")
            }
        }
        
        return nil
    }
    
    public func fetchNotes() -> [Note] {
        do {
            return (try? context.fetch(Note.fetchRequest())) ?? []
        }
    }
    
    public func fetchNote(with objectID: NSManagedObjectID) -> Note? {
        do {
            return (context.object(with: objectID)) as? Note ?? nil
        }
    }
    
    public func updataNote(with objectID: NSManagedObjectID, attributedText: NSAttributedString?) {
        
        if let attributedText = attributedText {
            do {
                let newText = try NSKeyedArchiver.archivedData(withRootObject: attributedText, requiringSecureCoding: false)
                
                guard let note = (context.object(with: objectID)) as? Note else { return }
                note.text = newText
                note.dateEdited = Date()

                // Зберігаємо зміни
                appDelegate.saveContext()
            } catch {
                print("Помилка під час архівування та збереження атрибутованого тексту: \(error)")
            }
        }
    }
    
    public func deletaNote(with objectID: NSManagedObjectID) {
        guard let note = context.object(with: objectID) as? Note else { return }
        context.delete(note)
        
        appDelegate.saveContext()
    }
}
