import SwiftUI

struct ReviewView: View {
    let deck: String
    var body: some View {
        Text("Reviewing \(deck)")
            .font(.largeTitle)
            .padding()
        VStack(spacing: 0) {
            HStack {
                ReviewButton(title: "Again", action: "1", color: .red)
                ReviewButton(title: "Hard", action: "2", color: .orange)
            }
            HStack {
                ReviewButton(title: "Good", action: "3", color: .yellow)
                ReviewButton(title: "Easy", action: "4", color: .green)
            }
            HStack {
                ReviewButton(title: "Next", action: "space", color: .gray)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ReviewButton: View {
    let title: String
    let action: String
    let color: Color
    
    var body: some View {
        Button(action: {
            sendAction(action: action)
        }) {
            Text(title)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(color.opacity(0.8))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }
    
    func sendAction(action: String) {
        let mapping: [String: Int] = [
            "1": 1,
            "2": 2,
            "3": 3,
            "4": 4,
            "space": 0
        ]
        
        AnkiAPI.invoke(action: "guiAnswerCard", params: ["ease": mapping[action] ?? 1]) { result in
            print("\(title) sent!")
        }
    }
}
