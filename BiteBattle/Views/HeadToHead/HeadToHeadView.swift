//
//  HeadToHeadView.swift
//  BiteBattle

import SwiftUI
import CoreLocation

struct HeadToHeadView: View {
    @Binding var path: NavigationPath
    @State private var zipCode: String = ""
    @State private var selectedCategories: [String] = []
    @State private var statusMessage: String?
    @State private var searchResults: [Restaurant] = []
    @State private var selectedRestaurants: Set<String> = []
    @State private var isSearching: Bool = false
    
    //Example categories
    let categories = ["Pizza", "Sushi", "Italian", "Ramen", "Burgers", "Mexican", "Chinese", "Indian", "Thai"]

    
    var body: some View {
        ZStack{
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Head-to-Head")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                    .shadow(radius: 3)
                
                AppTextField(placeholder: "Enter Zip Code", text: $zipCode, icon: "mappin.and.ellipse")
                
                MultiSelectMenu(options: categories, selected: $selectedCategories)

                AppButton(title: "Search", icon: "magnifyingglass", background: AppColors.primary, foreground: AppColors.textOnPrimary, isLoading: isSearching, isDisabled: zipCode.isEmpty || selectedCategories.isEmpty || isSearching) {
                    searchRestaurants()
                }
            }
            .hideKeyboardOnTap()
            .padding(.horizontal, 24)
        }
        
        
    }
    
    func searchRestaurants() {
        guard !zipCode.isEmpty, !selectedCategories.isEmpty else { return }
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
            for category in selectedCategories {
                fetchRestaurants(category: category, location: coordinates)
            }
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


}


struct MultiSelectMenu: View {
    let options: [String]
    @Binding var selected: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    if let index = selected.firstIndex(of: option) {
                        // Remove this item
                        selected.remove(at: index)
                    } else {
                        // Add this item
                        selected.append(option)
                    }
                } label: {
                    Label(
                        option,
                        systemImage: selected.contains(option) ? "checkmark" : ""
                    )
                }
            }
        } label: {
            HStack {
                Text(selected.isEmpty
                     ? "Select…"
                     : selected.joined(separator: ", "))
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 6).stroke())
        }
    }
}



#Preview {
    HeadToHeadView(path: .constant(NavigationPath()))
}
