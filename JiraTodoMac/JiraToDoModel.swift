//
//  JiraToDoModel.swift
//  JiraTodo
//
//  Created by Akram Husseini on 16/07/2025.
//

import Foundation

// Top-level response
struct SearchResult: Decodable {
    let issues: [JiraIssue]
}

struct JiraFields: Codable {
    let summary: String
    let status: Status

    struct Status: Codable {
        let name: String
    }
}

struct JiraIssue: Identifiable, Decodable {
    // Use the issue key as the stable id:
    var id: String { key }

    let key: String
    let summary: String
    let status: String

    private enum CodingKeys: String, CodingKey {
        case key, fields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        let fields = try container.decode(JiraFields.self, forKey: .fields)
        summary = fields.summary
        status  = fields.status.name
    }
}
