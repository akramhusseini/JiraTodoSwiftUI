//
//  JiraTodoViewModel.swift
//  JiraTodo
//
//  Created by Akram Husseini on 16/07/2025.
//

import SwiftUI
import Combine
import UserNotifications

class JiraTodoViewModel: ObservableObject {
    @Published var issues: [JiraIssue] = []
    @Published var loading = false

    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?

    init() {
        requestNotificationPermission()
        fetchIssues()

        // Poll every 5 minutes
        timer = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchIssues()
            }

        // Fetch again when app becomes active
        #if os(macOS)
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.fetchIssues() }
            .store(in: &cancellables)
        #endif
    }

    deinit {
        timer?.cancel()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func fetchIssues() {
        loading = true
        readToken { [weak self] token in
            DispatchQueue.main.async {
                guard let self = self, let token = token else {
                    self?.loading = false
                    return
                }

                print("Jira token:", token)

                let authString = "\(Constants.jiraEmail):\(token)"
                let authData = authString.data(using: .utf8)!
                let authHeader = "Basic \(authData.base64EncodedString())"

                var comps = URLComponents()
                comps.scheme = "https"
                comps.host   = "\(Constants.jiraDomain).atlassian.net"
                comps.path   = "/rest/api/3/search"
                comps.queryItems = [
                    .init(name: "jql", value: "assignee=currentUser() AND resolution is EMPTY AND statusCategory != Done ORDER BY created DESC"),
                    .init(name: "maxResults", value: "20"),
                    .init(name: "fields", value: "key,summary,status")
                ]

                guard let url = comps.url else {
                    self.loading = false
                    return
                }

                print("Fetching from URL:", url)

                var req = URLRequest(url: url, timeoutInterval: 20)
                req.setValue(authHeader, forHTTPHeaderField: "Authorization")
                req.setValue("application/json", forHTTPHeaderField: "Accept")

                URLSession.shared.dataTaskPublisher(for: req)
                    .map(\.data)
                    .decode(type: SearchResult.self, decoder: JSONDecoder())
                    .map(\.issues)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("Error fetching issues:", error)
                        }
                        self.loading = false
                    }, receiveValue: { newIssues in
                        print("Decoded issues:", newIssues)
                        self.handleListChange(new: newIssues)
                        self.issues = newIssues
                    })
                    .store(in: &self.cancellables)
            }
        }
    }

    private func handleListChange(new newIssues: [JiraIssue]) {
        let oldKeys = Set(issues.map(\.key))
        let newKeys = Set(newIssues.map(\.key))
        guard oldKeys != newKeys else { return }

        // Bring the app to front (macOS)
        #if os(macOS)
        NSApp.activate(ignoringOtherApps: true)
        #endif

        // Show notification
        let content = UNMutableNotificationContent()
        content.title = "New Jira activity"
        content.body  = "You have \(newIssues.count) open task\(newIssues.count == 1 ? "" : "s")."
        let req = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(req)
    }

    private func readToken(completion: @escaping (String?) -> Void) {
        if Constants.useTokenOverride, !Constants.tokenOverride.isEmpty {
            completion(Constants.tokenOverride)
            return
        }
        DispatchQueue.global().async {
            print("Token file URL:", Constants.tokenFile.path)
            let text = try? String(contentsOf: Constants.tokenFile, encoding: .utf8)
            print("Read token file, token:", text ?? "nil")
            completion(text?.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
