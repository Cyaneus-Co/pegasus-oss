import SwiftUI
import ComposableArchitecture

struct ZeroPostView: View {
    
    func noAction() {
        print("No Action")
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Image("ZeroPostImage")
                .resizable()
                .scaledToFill()
                .frame(width: 380, height: 500)
                .clipped()
            HStack {
                Spacer()
                Text("Cyaneus Offical")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                Spacer()
            }
            HStack {
                Text("Welcome to Cyaneus! Click the plus button at the top of the screen to get started.")
                    .foregroundColor(.white)
            }
        }
    }
}
struct ZeroPostView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Screen {
                ZeroPostView()
            }
        }
    }
}
