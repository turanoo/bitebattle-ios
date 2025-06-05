import SwiftUI
import CoreLocation
import Foundation

// Add model imports so types are available
// These are in the same target, so just ensure the files are in Compile Sources
// If not, use the correct module import if needed
// import BiteBattle_Core_Models (if using modules)

struct PollOptionView: View {
    let poll: Poll
    @Environment(\.presentationMode) var presentationMode

    @State private var zipCode: String = ""
    @State private var selectedCategory: String = ""
    @State private var isSearching: Bool = false
    @State private var statusMessage: String?
    @State private var searchResults: [Restaurant] = []
    @State private var selectedRestaurants: Set<String> = []
    @State private var isSubmitting: Bool = false
    @State private var pollResults: [PollOptionResult] = []
    @State private var isLoadingResults: Bool = false

    // Example categories
    let categories = ["Pizza", "Sushi", "Italian", "Ramen", "Burgers", "Mexican", "Chinese", "Indian", "Thai"]

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Select Options \(poll.name ?? "")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                    .padding(.top, 16)

                VStack(spacing: 12) {
                    AppTextField(placeholder: "Enter Zip Code", text: $zipCode, icon: "mappin.and.ellipse")
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag("")
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(10)
                    .shadow(radius: 1)

                    AppButton(title: "Search", icon: "magnifyingglass", background: AppColors.primary, foreground: AppColors.textOnPrimary, isLoading: isSearching, isDisabled: zipCode.isEmpty || selectedCategory.isEmpty || isSearching) {
                        searchRestaurants()
                    }
                }
                .padding(.horizontal, 24)

                if isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .padding()
                } else if let status = statusMessage {
                    Text(status)
                        .foregroundColor(AppColors.error)
                        .font(.footnote)
                        .padding(.top, 8)
                        .shadow(radius: 1)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(searchResults) { restaurant in
                            Button(action: {
                                toggleSelection(for: restaurant.place_id)
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    if let photoRef = restaurant.photos?.first?.photo_reference {
                                        AsyncImage(url: photoURL(photoRef)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            AppColors.disabled // replaces Color.gray.opacity(0.3)
                                        }
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                    } else {
                                        AppColors.disabled // replaces Color.gray.opacity(0.3)
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(restaurant.name)
                                            .font(.headline)
                                            .foregroundColor(AppColors.secondary) // replaces .pink
                                        if let rating = restaurant.rating {
                                            Text("Rating: \(String(format: "%.1f", rating))")
                                                .font(.subheadline)
                                                .foregroundColor(AppColors.textOnPrimary) // replaces .white
                                        }
                                        if let address = restaurant.address, !address.isEmpty {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(AppColors.textOnPrimary) // replaces .white
                                        }
                                    }
                                    Spacer()
                                    if selectedRestaurants.contains(restaurant.place_id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.accent) // replaces .green
                                            .font(.title2)
                                    }
                                }
                                .padding()
                                .background(selectedRestaurants.contains(restaurant.place_id) ? AppColors.tileSelected : AppColors.tileBackground)
                                .cornerRadius(14)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }

                if !searchResults.isEmpty {
                    AppButton(title: isSubmitting ? "Submitting..." : "Submit", icon: "paperplane.fill", background: AppColors.secondary, foreground: AppColors.textOnPrimary, isLoading: isSubmitting, isDisabled: selectedRestaurants.isEmpty || isSubmitting) {
                        submitSelectedOptions()
                    }
                    .padding(.top, 8)
                }

                // Show poll results if available
                if isLoadingResults {
                    ProgressView("Loading Results...")
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .padding()
                } else if !pollResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Poll Options:")
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                        ForEach(pollResults) { option in
                            HStack {
                                Text(option.option_name)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text("Votes: \(option.vote_count)")
                                    .foregroundColor(AppColors.secondary)
                            }
                            .padding(8)
                            .background(AppColors.tileBackground)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top, 16)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Add Option")
    }

    func searchRestaurants() {
        guard !zipCode.isEmpty, !selectedCategory.isEmpty else { return }
        statusMessage = nil
        isSearching = true
        searchResults = []
        selectedRestaurants = []

        // Geocode zip code to coordinates
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Invalid zip code: \(error.localizedDescription)"
                    self.isSearching = false
                }
                return
            }
            guard let location = placemarks?.first?.location else {
                DispatchQueue.main.async {
                    self.statusMessage = "Could not find location for zip code."
                    self.isSearching = false
                }
                return
            }
            let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            fetchRestaurants(category: selectedCategory, location: coordinates)
        }
    }

    func fetchRestaurants(category: String, location: String) {
        isSearching = true
        statusMessage = nil
        APIClient.shared.searchRestaurants(category: category, location: location) { result in
            DispatchQueue.main.async {
                isSearching = false
                switch result {
                case .success(let restaurants):
                    searchResults = restaurants
                case .failure(let error):
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    func toggleSelection(for placeId: String) {
        if selectedRestaurants.contains(placeId) {
            selectedRestaurants.remove(placeId)
        } else {
            selectedRestaurants.insert(placeId)
        }
    }

    func submitSelectedOptions() {
        guard !selectedRestaurants.isEmpty else { return }
        isSubmitting = true
        statusMessage = nil

        let selected = searchResults.filter { selectedRestaurants.contains($0.place_id) }
        let payload: [[String: Any]] = selected.map { restaurant in
            let imageUrl = restaurant.photos?.first.flatMap { photoURL($0.photo_reference)?.absoluteString } ?? ""
            return [
                "restaurant_id": restaurant.place_id,
                "name": restaurant.name,
                "image_url": imageUrl as String,
                "menu_url": "" // You can add menu URL if available
            ]
        }

        APIClient.shared.addPollOptions(pollId: poll.id, options: payload) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    statusMessage = "Failed: \(error.localizedDescription)"
                }
            }
        }
    }


    func photoURL(_ reference: String) -> URL? {
        // Replace with your backend's photo endpoint if needed
        // This is a placeholder for Google Places API photo endpoint
        let maxWidth = 400
        return URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(reference)&key=AIzaSyCHFSr3LuANYJu4dALcGZquzF0MX8OSKsI")
    }
}

#if DEBUG
struct PollOptionView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a mock Poll for preview (update for new Poll struct)
        PollOptionView(poll: Poll(
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
