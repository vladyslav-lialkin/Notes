//
//  Note+CoreDataProperties.swift
//  Notes
//
//  Created by Влад Лялькін on 11.09.2023.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var dateEdited: Date?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var text: Data?

    @NSManaged public var category: Category?

}

extension Note : Identifiable {

}
