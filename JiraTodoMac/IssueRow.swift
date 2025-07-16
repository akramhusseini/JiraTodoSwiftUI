//
//  IssueRow.swift
//  JiraTodo
//
//  Created by Akram Husseini on 16/07/2025.
//

import SwiftUI

struct IssueRow: View {
    let issue: JiraIssue

    var body: some View {
        HStack(spacing: 12) {
            Text(issue.key.split(separator: "-").last.map(String.init) ?? issue.key)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(statusColor(issue.status))
                )
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.summary)
                Text(issue.status)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(statusColor(issue.status).opacity(0.2)))
                    .foregroundColor(statusColor(issue.status))
            }
        }
        .padding(.vertical, 4)
    }

    private func statusColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "in progress":         return .orange
        case "lead review", "to do": return .blue
        default:                    return .gray
        }
    }
}

#Preview {
    IssueRow(issue: JiraIssue(
        key: "JIRA-29139",
        summary: "SwiftUI Advanced Learning (Advanced Level)",
        status: "Ready for Dev"
    ))
}
