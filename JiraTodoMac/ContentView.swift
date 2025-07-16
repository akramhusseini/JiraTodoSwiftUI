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

#Preview {
    ContentView()
}
