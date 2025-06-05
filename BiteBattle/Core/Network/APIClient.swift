// APIClient.swift
// Centralized API logic

import Foundation
import CoreLocation

// No import needed for models if in same target, just ensure files are in Compile Sources
// Endpoints.swift is in the same target, so Endpoints is available

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private var token: String? {
        UserDefaults.standard.string(forKey: "authToken")
    }

    private func makeRequest(url: URL, method: String = "GET", body: Data? = nil, contentType: String? = nil) -> URLRequest? {
        guard let token = token, !token.isEmpty else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = body
        return request
    }

    // MARK: - Authentication
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: Endpoints.login) else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: String] = [
            "email": email,
            "password": password
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(APIError.noData)); return
        }
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(APIError.noData)); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(APIError.noData))
                }
            } catch { completion(.failure(error)) }
        }.resume()
    }

    func register(email: String, password: String, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: Endpoints.register) else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: String] = [
            "email": email,
            "password": password,
            "name": name
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(APIError.noData)); return
        }
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(APIError.noData)); return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(APIError.noData))
                }
            } catch { completion(.failure(error)) }
        }.resume()
    }

    // MARK: - Polls
    func fetchPolls(completion: @escaping (Result<[Poll], Error>) -> Void) {
        guard let url = URL(string: Endpoints.polls), let request = makeRequest(url: url) else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(APIError.noData)); return }
            do {
                let polls = try JSONDecoder().decode([Poll].self, from: data)
                completion(.success(polls))
            } catch { completion(.failure(error)) }
        }.resume()
    }

    func createPoll(name: String, completion: @escaping (Result<Poll, Error>) -> Void) {
        guard let url = URL(string: Endpoints.polls),
              let body = try? JSONSerialization.data(withJSONObject: ["name": name]),
              let request = makeRequest(url: url, method: "POST", body: body, contentType: "application/json") else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async { // Ensure UI state changes are on main thread
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.failure(APIError.noData)); return }
                do {
                    let poll = try JSONDecoder().decode(Poll.self, from: data)
                    completion(.success(poll))
                } catch { completion(.failure(error)) }
            }
        }.resume()
    }

    // Updated joinPoll to use pollId and inviteCode in body
    // Make sure to import or define the Poll model at the top if needed:
    // import YourModelModule

    func joinPoll(pollId: String, inviteCode: String, completion: @escaping (Result<Poll, Error>) -> Void) {
        guard let url = URL(string: Endpoints.joinPoll(pollId: pollId)),
              let body = try? JSONSerialization.data(withJSONObject: ["invite_code": inviteCode]),
              let request = makeRequest(url: url, method: "POST", body: body, contentType: "application/json") else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(APIError.noData)); return }
            do {
                let poll = try JSONDecoder().decode(Poll.self, from: data)
                completion(.success(poll))
            } catch { completion(.failure(error)) }
        }.resume()
    }

    func fetchPollResults(pollId: String, completion: @escaping (Result<[PollOptionResult], Error>) -> Void) {
        guard let url = URL(string: Endpoints.pollResults(pollId)), let request = makeRequest(url: url) else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(APIError.noData)); return }
            do {
                let results = try JSONDecoder().decode([PollOptionResult].self, from: data)
                completion(.success(results))
            } catch { completion(.failure(error)) }
        }.resume()
    }

    func addPollOptions(pollId: String, options: [[String: Any]], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: Endpoints.pollOptions(pollId)),
              let body = try? JSONSerialization.data(withJSONObject: options),
              let request = makeRequest(url: url, method: "POST", body: body, contentType: "application/json") else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error { completion(.failure(error)); return }
            completion(.success(()))
        }.resume()
    }

    func searchRestaurants(category: String, location: String, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        guard let url = URL(string: "\(Endpoints.restaurantSearch)?q=\(category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&location=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), let request = makeRequest(url: url) else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(APIError.noData)); return }
            do {
                let restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
                completion(.success(restaurants))
            } catch { completion(.failure(error)) }
        }.resume()
    }

    func updatePoll(pollId: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: Endpoints.updatePoll(pollId)),
              let body = try? JSONSerialization.data(withJSONObject: ["name": name]),
              let request = makeRequest(url: url, method: "PUT", body: body, contentType: "application/json") else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error { completion(.failure(error)); return }
            completion(.success(()))
        }.resume()
    }

    func deletePoll(pollId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: Endpoints.deletePoll(pollId)),
              let request = makeRequest(url: url, method: "DELETE") else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error { completion(.failure(error)); return }
            completion(.success(()))
        }.resume()
    }

    // MARK: - Account
    func fetchAccount(completion: @escaping (Result<AccountInfo, Error>) -> Void) {
        guard let url = URL(string: Endpoints.account), let token = token, !token.isEmpty else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(APIError.noData)); return }
            do {
                let account = try JSONDecoder().decode(AccountInfo.self, from: data)
                completion(.success(account))
            } catch { completion(.failure(error)) }
        }.resume()
    }

    func updateAccount(name: String, email: String, currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: Endpoints.account), let token = token, !token.isEmpty else {
            completion(.failure(APIError.notLoggedIn)); return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var payload: [String: String] = [
            "name": name,
            "email": email
        ]
        if !currentPassword.isEmpty && !newPassword.isEmpty {
            payload["current_password"] = currentPassword
            payload["new_password"] = newPassword
        }
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(APIError.noData)); return
        }
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["error"] as? String {
                    completion(.failure(APIError.unauthorized(message)))
                } else {
                    completion(.failure(APIError.unauthorized("Unauthorized")))
                }
                return
            }
            completion(.success(()))
        }.resume()
    }

    enum APIError: Error {
        case notLoggedIn
        case noData
        case unauthorized(String)
    }
}
