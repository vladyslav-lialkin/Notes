//
//  Sort.swift
//  Notes
//
//  Created by Влад Лялькін on 01.10.2023.
//

import Foundation

enum SortBy: Int {
    case dateEdited
    case dateCreated
    case title
}

class Sort {
    static func date(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.day, .hour], from: date, to: Date())
        
        if let day = dateComponents.day, day <= 7 {
            if calendar.isDateInToday(date) {
                if abs(dateComponents.hour ?? 0) <= 12 {
                    dateFormatter.dateFormat = "HH:mm"
                    return "\(dateFormatter.string(from: date))"
                }
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                let dayOfWeek = calendar.component(.weekday, from: date)
                let dayOfWeekString = dateFormatter.weekdaySymbols[dayOfWeek - 1]
                return dayOfWeekString
            }
        }
        return dateFormatter.string(from: date)
    }
    
    static func notes(notes: [Note], sort: SortBy) -> [Section] {
        let dateFormatter = DateFormatter()
        let date = Date()

        var todayNotes: [Note] = []
        var yesterdayNotes: [Note] = []
        var last7DaysNotes: [Note] = []
        var last30DaysNotes: [Note] = []
        var monthsSections: [String: [Note]] = [:]
        var monthsString: [String] = []
        var yearsSections: [String: [Note]] = [:]

        let calendar = Calendar.current
        
        let getDate: (Note) -> Date?
            
        if sort == .dateEdited {
            getDate = { $0.dateEdited }
        } else {
            getDate = { $0.dateCreated }
        }

        for note in notes {
            guard let noteDate = getDate(note) else { continue }
            
            let dateComponents = calendar.dateComponents([.day, .year], from: noteDate, to: date)
            
            if calendar.isDate(noteDate, equalTo: date, toGranularity: .year) {
                if calendar.isDateInToday(noteDate) {
                    todayNotes.append(note)
                } else if calendar.isDateInYesterday(noteDate) {
                    yesterdayNotes.append(note)
                } else if let day = dateComponents.day, day <= 6 + 2 {
                    last7DaysNotes.append(note)
                } else if let day = dateComponents.day, day <= 30 + 6 + 2 {
                    last30DaysNotes.append(note)
                } else {
                    let month = calendar.component(.month, from: noteDate)
                    let monthString = dateFormatter.monthSymbols[month - 1]
                    
                    if var section = monthsSections[monthString] {
                        section.append(note)
                        monthsSections[monthString] = section
                    } else {
                        monthsString += [monthString]
                        monthsSections[monthString] = [note]
                    }
                }
            } else {
                dateFormatter.dateFormat = "yyyy"
                let yearString = dateFormatter.string(from: noteDate)
                
                if var section = yearsSections[yearString] {
                    section.append(note)
                    yearsSections[yearString] = section
                } else {
                    yearsSections[yearString] = [note]
                }
            }
        }

        var categorizedNotes = [Section]()

        if !todayNotes.isEmpty {
            categorizedNotes.append(Section(title: "Today", notes: todayNotes))
        }
        if !yesterdayNotes.isEmpty {
            categorizedNotes.append(Section(title: "Yesterday", notes: yesterdayNotes))
        }
        if !last7DaysNotes.isEmpty {
            categorizedNotes.append(Section(title: "Previous 7 days", notes: last7DaysNotes))
        }
        if !last30DaysNotes.isEmpty {
            categorizedNotes.append(Section(title: "Previous 30 days", notes: last30DaysNotes))
        }
        
        for month in monthsString {
            
            categorizedNotes.append(Section(title: month, notes: monthsSections[month]!))
        }

        for (year, yearNotes) in yearsSections.sorted(by: { $0.key > $1.key}) {
            categorizedNotes.append(Section(title: year, notes: yearNotes))
        }
        
        return categorizedNotes
    }
}
