import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState.Binding var focused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Enter your location", text: $searchText)
                .focused($focused)
            //Image(systemName: "mic")
                //.foregroundColor(.gray)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
