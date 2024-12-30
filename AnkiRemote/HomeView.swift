import SwiftUI

struct HomeView: View {
    @State private var decks: [String] = []
    @State private var isLoading = true
    @State private var selectedDeck: String? = nil
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading decks...")
                } else if decks.isEmpty {
                    Text("No decks found. Please add a deck to Anki.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(decks, id: \.self) { deck in
                        Button(action: {
                            selectedDeck = deck
                            showConfirmation = true
                        }) {
                            Text(deck)
                                .font(.headline)
                        }
                    }
                }
            }
            .onAppear(perform: fetchDecks)
            .navigationTitle("Select a Deck")
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("Start Studying?"),
                    message: Text("Start studying \(selectedDeck ?? "this deck")?"),
                    primaryButton: .default(Text("Yes"), action: {
                        if let deck = selectedDeck {
                            startReview(deck: deck)
                        }
                    }),
                    secondaryButton: .cancel(Text("No"))
                )
            }
        }
    }
    
    func fetchDecks() {
        isLoading = true
        AnkiAPI.invoke(action: "deckNames") { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let deckList):
                    decks = deckList
                case .failure:
                    decks = []
                }
            }
        }
    }
    
    func startReview(deck: String) {
        // Step 1: Open the deck overview
        AnkiAPI.invoke(action: "guiDeckReview", params: ["name": deck]) { result in
            if let result = result as? Bool, result {
                print("Deck \(deck) opened for study.")
                
                // Step 2: Trigger Study Now directly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AnkiAPI.invoke(action: "guiShowQuestion") { questionResult in
                        if let questionResult = questionResult as? Bool, questionResult {
                            print("Study session triggered for \(deck).")
                        } else {
                            print("Failed to show first card. Deck may have no due cards.")
                        }
                    }
                }
            } else {
                print("Failed to open \(deck).")
            }
        }
    }
}


