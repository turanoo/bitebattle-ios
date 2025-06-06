import SwiftUI
import Foundation
import CoreLocation

struct PollDetailView: View {
    let poll: Poll

    @State private var results: [PollOptionResult] = []
    @State private var isLoading: Bool = false
    @State private var statusMessage: String?
    @State private var showAddOption: Bool = false
    @State private var currentUserId: String? = nil

    var body: some View {
        AppBackground {
            VStack(spacing: 24) {
                headerView
                statusOrProgressView
                optionsListView
                Spacer()
                addButton
            }
            .padding()
            .onAppear {
                fetchResults()
                fetchCurrentUserId()
            }
        }
    }

    private var headerView: some View {
        Text(poll.name ?? "Untitled Poll")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(AppColors.textPrimary)
            .shadow(radius: 2)
            .padding(.top, 24)
    }

    private var statusOrProgressView: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                    .padding()
            } else if let status = statusMessage {
                Text(status)
                    .foregroundColor(AppColors.textOnPrimary)
                    .font(.footnote)
                    .padding(.top, 8)
                    .shadow(radius: 1)
            } else if results.isEmpty {
                Text("No options yet.")
                    .foregroundColor(AppColors.textOnPrimary)
                    .font(.headline)
                    .padding()
                    .shadow(radius: 1)
            }
        }
    }

    private var optionsListView: some View {
        let backgroundColors = AppColors.pollTileColors
        let borderColor = AppColors.border
        return ScrollView {
            VStack(spacing: 18) {
                ForEach(Array(results.enumerated()), id: \.element.option_id) { (idx, option) in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(option.option_name)
                                .font(.headline)
                                .foregroundColor(AppColors.secondary)
                            Spacer()
                            Text("Votes: \(option.vote_count)")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textOnPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppColors.secondary.opacity(0.7))
                                .cornerRadius(8)
                        }
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Voter IDs:")
                                .font(.caption)
                                .foregroundColor(AppColors.secondary)
                            if option.voter_ids.isEmpty {
                                Text("No votes yet")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(option.voter_ids, id: \.self) { voter in
                                    Text(voter)
                                        .font(.caption2)
                                        .foregroundColor(AppColors.textOnPrimary)
                                }
                            }
                        }
                        // Voting/Unvoting Button
                        if let userId = currentUserId {
                            let hasVoted = option.voter_ids.contains(userId)
                            AppButton(
                                title: hasVoted ? "Unvote" : "Vote",
                                icon: hasVoted ? "xmark.circle" : "checkmark.circle",
                                background: hasVoted ? AppColors.error : AppColors.primary,
                                foreground: AppColors.textOnPrimary,
                                isLoading: false,
                                isDisabled: isLoading,
                                action: {
                                    if hasVoted {
                                        unvote(optionId: option.option_id)
                                    } else {
                                        vote(optionId: option.option_id)
                                    }
                                }
                            )
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(backgroundColors[idx % backgroundColors.count])
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: 2)
                    )
                    .shadow(color: AppColors.textSecondary.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: 400)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .center)
            .animation(.easeInOut(duration: 0.18), value: results)
        }
    }

    private var addButton: some View {
        AppButton(
            title: "Add Option",
            icon: "plus.circle.fill",
            background: AppColors.primary,
            foreground: AppColors.textOnPrimary,
            isLoading: false,
            isDisabled: false
        ) {
            showAddOption = true
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
        .sheet(isPresented: $showAddOption, onDismiss: fetchResults) {
            PollOptionView(poll: poll)
        }
    }

    private func fetchResults() {
        isLoading = true
        statusMessage = nil
        results = []
        APIClient.shared.fetchPollResults(pollId: poll.id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let pollOptions):
                    results = pollOptions
                case .failure(let error):
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchCurrentUserId() {
        APIClient.shared.fetchAccount { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    currentUserId = account.id // assumes AccountInfo has id
                case .failure:
                    currentUserId = nil
                }
            }
        }
    }

    private func vote(optionId: String) {
        isLoading = true
        statusMessage = nil
        APIClient.shared.vote(pollId: poll.id, optionId: optionId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    fetchResults()
                case .failure(let error):
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    private func unvote(optionId: String) {
        isLoading = true
        statusMessage = nil
        APIClient.shared.unvote(pollId: poll.id, optionId: optionId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    fetchResults()
                case .failure(let error):
                    statusMessage = error.localizedDescription
                }
            }
        }
    }
}

// Conform PollOptionResult to Equatable for animation
extension PollOptionResult: Equatable {
    static func == (lhs: PollOptionResult, rhs: PollOptionResult) -> Bool {
        lhs.option_id == rhs.option_id &&
        lhs.option_name == rhs.option_name &&
        lhs.vote_count == rhs.vote_count &&
        lhs.voter_ids == rhs.voter_ids
    }
}

#if DEBUG
struct PollDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a mock Poll for preview (update for new Poll struct)
        PollDetailView(poll: Poll(
            id: "1",
            name: "Sample Poll",
            invite_code: "1234",
            role: nil,
            members: [],
            created_by: "owner",
            created_at: "",
            updated_at: ""
        ))
    }
}
#endif
