//
//  ReportManager.swift
//  HerHub
//
//  Created by Driksha Thakur on 11/11/25.
//

import Foundation

class ReportManager {

    static let shared = ReportManager()
    private var reports: [Report] = []
    private let fileURL: URL

    private init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = directory.appendingPathComponent("reports").appendingPathExtension("plist")
        loadReports()
    }

    func getAllReports() -> [Report] {
        return reports
    }

    func addReport(postID: UUID, communityID: UUID, reporterID: UUID, reason: String, notes: String?) {
        let report = Report(postID: postID, communityID: communityID, reporterID: reporterID, reason: reason, notes: notes)
        reports.append(report)
        saveReports()
    }

    private func loadReports() {
        if let data = try? Data(contentsOf: fileURL) {
            let decoder = PropertyListDecoder()
            if let decoded = try? decoder.decode([Report].self, from: data) {
                reports = decoded
                return
            }
        }
        saveReports() // create empty plist if missing
    }

    private func saveReports() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        if let data = try? encoder.encode(reports) {
            try? data.write(to: fileURL, options: .noFileProtection)
        }
    }
}


