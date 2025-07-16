//
//  ContentView.swift
//  JiraTodo
//
//  Created by Akram Husseini on 16/07/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = JiraTodoViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Akram's Jira Todo")
                    .font(.title)
                    .padding(.leading)
                Spacer()
                Button(action: { vm.fetchIssues() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .padding()
            }
            Divider()
            if vm.loading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            }
            else if vm.issues.isEmpty {
                Text("🎉 No open Jira tasks!")
                    .font(.title2)
                    .padding()
            }
            else {
                List(vm.issues) { issue in
                    IssueRow(issue: issue)
                        .onTapGesture {
                            if let url = URL(string: "https://\(Constants.jiraDomain).atlassian.net/browse/\(issue.key)") {
                                #if os(macOS)
                                NSWorkspace.shared.open(url)
                                #else
                                UIApplication.shared.open(url)
                                #endif
                            }
                        }
                }
                .listStyle(.plain)
                .refreshable {
                    vm.fetchIssues()
                }
            }
        }
        .frame(minWidth: 400, minHeight: 600)
    }
}

struct IssueRow: View {
    let issue: JiraIssue

    var body: some View {
        HStack(spacing: 12) {
            Text(issue.key.split(separator: "-").last.map(String.init) ?? issue.key)
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(Circle().fill(statusColor(issue.status)))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.summary)
                Text(issue.status)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor(issue.status).opacity(0.2))
                    .cornerRadius(4)
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
    ContentView()
}
