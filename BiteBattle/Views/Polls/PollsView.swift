import Foundation
import SwiftUI


struct PollsView: View {
    @Binding var path: NavigationPath
    @State private var polls: [Poll] = []
    @State private var isLoading: Bool = false
    @State private var statusMessage: String?
    @State private var showAddPoll: Bool = false
    @State private var newPollName: String = ""
    @State private var isCreatingPoll: Bool = false
    @State private var showJoinPoll: Bool = false
    @State private var inviteCode: String = ""
    @State private var isJoiningPoll: Bool = false
    @State private var selectedPoll: Poll? = nil

    var body: some View {
            AppBackground {
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        AppIcon()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                    StatusOrLoadingView(
                        isLoading: isLoading,
                        statusMessage: statusMessage,
                        isEmpty: polls.isEmpty,
                        emptyText: "No polls yet. Create or join one!"
                    )
                    // Hidden navigationDestination for programmatic navigation
                    .navigationDestination(isPresented: Binding(
                        get: { self.selectedPoll != nil },
                        set: { if !$0 { self.selectedPoll = nil } }
                    )) {
                        if let selectedPoll = selectedPoll {
                            PollDetailView(poll: selectedPoll)
                        }
                    }
                    PollsListView(polls: polls, onRefresh: { fetchPolls() })
                    PollActionButtons(
                        showAddPoll: $showAddPoll,
                        showJoinPoll: $showJoinPoll,
                        newPollName: $newPollName,
                        isCreatingPoll: $isCreatingPoll,
                        createPoll: createPoll,
                        inviteCode: $inviteCode,
                        isJoiningPoll: $isJoiningPoll,
                        joinPoll: joinPoll
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .onAppear { fetchPolls() }
            }
            .sheet(isPresented: $showAddPoll) {
                AppBackground {
                    VStack(spacing: 16) {
                        AppTextField(placeholder: "Poll Name", text: $newPollName)
                        AppButton(
                            title: isCreatingPoll ? "Creating..." : "Create",
                            isLoading: isCreatingPoll,
                            isDisabled: newPollName.isEmpty,
                            action: createPoll
                        )
                        Button("Cancel") { showAddPoll = false }
                            .foregroundColor(AppColors.error)
                    }
                    .padding()
                }
                .interactiveDismissDisabled(isCreatingPoll)
                .onChange(of: isCreatingPoll) { _, _ in
                    if !isCreatingPoll {
                        showAddPoll = false
                    }
                }
            }
            .sheet(isPresented: $showJoinPoll) {
                AppBackground {
                    VStack(spacing: 16) {
                        Text("Enter Invite Code")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        AppTextField(placeholder: "Invite Code", text: $inviteCode)
                        AppButton(
                            title: isJoiningPoll ? "Joining..." : "Join",
                            isLoading: isJoiningPoll,
                            isDisabled: inviteCode.isEmpty,
                            action: joinPoll
                        )
                        Button("Cancel") { showJoinPoll = false }
                            .foregroundColor(AppColors.error)
                    }
                    .padding()
                }
                .interactiveDismissDisabled(isJoiningPoll)
            }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                AccountNavButton()
            }
        }
    }

    func fetchPolls(completion: (([Poll]) -> Void)? = nil) {
        isLoading = true
        APIClient.shared.fetchPolls { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let polls):
                    let sortedPolls = polls.sorted { ($0.updated_at ?? "") > ($1.updated_at ?? "") }
                    self.polls = sortedPolls
                    self.statusMessage = nil
                    completion?(sortedPolls)
                case .failure(let error):
                    self.statusMessage = error.localizedDescription
                    completion?([])
                }
            }
        }
    }

    func createPoll() {
        guard !newPollName.isEmpty else { return }
        isCreatingPoll = true
        APIClient.shared.createPoll(name: newPollName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    newPollName = ""
                    isCreatingPoll = false
                    // After creation, refresh polls just like onAppear
                    fetchPolls()
                case .failure(let error):
                    isCreatingPoll = false
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    func joinPoll() {
        guard !inviteCode.isEmpty else { return }
        isJoiningPoll = true
        APIClient.shared.fetchPolls { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let polls):
                    if let poll = polls.first(where: { $0.invite_code == inviteCode }) {
                        APIClient.shared.joinPoll(pollId: poll.id, inviteCode: inviteCode) { joinResult in
                            DispatchQueue.main.async {
                                switch joinResult {
                                case .success(_):
                                    inviteCode = ""
                                    isJoiningPoll = false
                                    // After joining, refresh polls just like onAppear
                                    fetchPolls()
                                case .failure(let error):
                                    isJoiningPoll = false
                                    statusMessage = error.localizedDescription
                                }
                            }
                        }
                    } else {
                        isJoiningPoll = false
                        statusMessage = "No poll found for invite code."
                    }
                case .failure(let error):
                    isJoiningPoll = false
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    struct GradientBackground<Content: View>: View {
        let content: Content
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary.opacity(0.7), AppColors.secondary.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                content
            }
        }
    }

    struct AppIcon: View {
        var body: some View {
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(AppColors.primary)
                .shadow(radius: 6)
        }
    }

    struct TitleText: View {
        let title: String
        var body: some View {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    struct StatusOrLoadingView: View {
        let isLoading: Bool
        let statusMessage: String?
        let isEmpty: Bool
        let emptyText: String
        var body: some View {
            if isLoading {
                ProgressView()
            } else if let status = statusMessage {
                Text(status)
                    .foregroundColor(AppColors.error)
            } else if isEmpty {
                Text(emptyText)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    struct PollTile: View {
        let poll: Poll
        let colorIndex: Int
        var onRefresh: (() -> Void)? = nil

        // Use color palette from AppColors
        private let backgroundColors = AppColors.pollTileColors
        private let borderColor = AppColors.border

        var isOwner: Bool {
            poll.role == "owner"
        }

        // Format the created_at string to MM/dd/yy, or show as-is if parsing fails
        var formattedDate: String {
            let input = poll.created_at ?? ""
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: input) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yy"
                return formatter.string(from: date)
            } else {
                return input.isEmpty ? "Unknown date" : input
            }
        }

        var numberOfMembers: Int {
            (poll.members ?? []).count
        }

        @State private var showEditSheet = false
        @State private var showDeleteAlert = false
        @State private var showInviteAlert = false

        var body: some View {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: isOwner ? "crown.fill" : "person.2.fill")
                        .foregroundColor(AppColors.textSecondary)
                        .imageScale(.large)
                    Spacer()
                    if isOwner {
                        HStack(spacing: 16) {
                            Button(action: { showEditSheet = true }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                    .imageScale(.large)
                                    .accessibilityLabel("Edit Poll")
                            }
                            Button(action: { showDeleteAlert = true }) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(AppColors.error)
                                    .imageScale(.large)
                                    .accessibilityLabel("Delete Poll")
                            }
                            Button(action: {showInviteAlert = true}) {
                                Image(systemName: "link.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                    .imageScale(.large)
                                    .accessibilityLabel("Get Poll Code")
                                
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    
                }
                .padding(.bottom, 2)

                Text(poll.name ?? "Untitled Poll")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)


                HStack {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(borderColor)
                            .imageScale(.small)
                        Text("\(numberOfMembers)")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColors[colorIndex % backgroundColors.count])
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(color: AppColors.textSecondary.opacity(0.08), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 16)
            .frame(maxWidth: 400)
            .sheet(isPresented: $showEditSheet) {
                EditPollSheet(poll: poll, onUpdate: { updatedName in
                    updatePollName(updatedName)
                })
            }
            .alert("Delete Poll?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { deletePoll() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this poll? This cannot be undone.")
            }
            .alert("Invite Code", isPresented: $showInviteAlert) {
                Button("Copy") {
                    UIPasteboard.general.string = poll.invite_code ?? ""
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text(poll.invite_code ?? "—")
            }
        }

        private func updatePollName(_ newName: String) {
            guard let pollId = poll.id as String? else { return }
            APIClient.shared.updatePoll(pollId: pollId, name: newName) { result in
                switch result {
                case .success:
                    // Optionally show success message
                    print("Poll updated successfully")
                    onRefresh?() // Refresh the poll list after edit
                case .failure(let error):
                    // Optionally show error
                    print("Update failed: \(error.localizedDescription)")
                }
            }
        }

        private func deletePoll() {
            guard let pollId = poll.id as String? else { return }
            APIClient.shared.deletePoll(pollId: pollId) { result in
                switch result {
                case .success:
                    print("Poll deleted successfully")
                    onRefresh?() // Refresh the poll list after delete
                case .failure(let error):
                    print("Delete failed: \(error.localizedDescription)")
                }
            }
        }
    }

    struct PollActionButtons: View {
        @Binding var showAddPoll: Bool
        @Binding var showJoinPoll: Bool
        @Binding var newPollName: String
        @Binding var isCreatingPoll: Bool
        let createPoll: () -> Void
        @Binding var inviteCode: String
        @Binding var isJoiningPoll: Bool
        let joinPoll: () -> Void
        var body: some View {
            HStack(spacing: 16) {
                Button(action: { showAddPoll = true }) {
                    Text("Create Poll")
                        .fontWeight(.semibold)
                        .padding()
                        .background(AppColors.primary.opacity(0.9))
                        .foregroundColor(AppColors.textOnPrimary)
                        .cornerRadius(10)
                }
                Button(action: { showJoinPoll = true }) {
                    Text("Join Poll")
                        .fontWeight(.semibold)
                        .padding()
                        .background(AppColors.secondary.opacity(0.9))
                        .foregroundColor(AppColors.textOnPrimary)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 12)
        }
    }

    struct EditPollSheet: View {
        let poll: Poll
        var onUpdate: (String) -> Void
        @Environment(\.dismiss) private var dismiss
        @State private var pollName: String = ""
        var body: some View {
            AppBackground {
                VStack(spacing: 16) {
                    Text("Edit Poll Name")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    AppTextField(placeholder: "Poll Name", text: $pollName)
                    AppButton(
                        title: "Save",
                        isLoading: false,
                        isDisabled: pollName.isEmpty,
                        action: {
                            onUpdate(pollName)
                            dismiss()
                        }
                    )
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.error)
                }
                .padding()
            }
            .onAppear { pollName = poll.name ?? ""
                print(poll.invite_code) }
        }
    }

    struct PollsListView: View {
        let polls: [Poll]
        let onRefresh: () -> Void
        var body: some View {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(polls.enumerated()), id: \.element.id) { (idx, poll) in
                        NavigationLink(destination: PollDetailView(poll: poll)) {
                            PollTile(poll: poll, colorIndex: idx, onRefresh: onRefresh)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            }
        }
    }
}

#if DEBUG
struct PollsView_Previews: PreviewProvider {
    static var previews: some View {
        PollsView(path: .constant(NavigationPath()))
    }
}
#endif


