import SwiftUI

struct FlaggedPostView: View {
    var body: some View {
        VStack {
            Image("PegasusAvatar")
                .resizable()
                .frame(width: 340, height: 360, alignment: .center)
                .padding()
            HStack {
                HStack {
                    ThumbnailView("PegasusAvatar")
                    Text("System Account:").fontWeight(.bold)
                        .lineLimit(2)
                    Text("This post has been flagged")
                        .lineLimit(2)
                }
                .padding()
            }
        }
        .background(
            Image("leaves")
                .resizable()
                .scaledToFill()
        )
    }
}

struct FlaggedPostView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            FlaggedPostView()
        }
    }
}
