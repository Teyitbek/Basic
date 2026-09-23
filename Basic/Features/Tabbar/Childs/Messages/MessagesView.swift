import SwiftUI

struct MessagesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 150)
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("No messages")
                .font(.title)
                .bold()
                .foregroundColor(.black)
            
            Text("Start a new conversation")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
#Preview {
    MessagesView()
}
