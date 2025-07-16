//
//  Constants.swift
//  JiraTodo
//
//  Created by Akram Husseini on 16/07/2025.
//

import Foundation

struct Constants {
    static let jiraEmail       = "akramh@motory.com"
    static let jiraDomain      = "ksa-motory"
    static let tokenFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".jira_token")
    static let useTokenOverride = false
    static let tokenOverride    = ""
}
