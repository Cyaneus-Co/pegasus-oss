import SwiftUI

extension Color {
    static let appBackground = Color("Main")
}

struct Screen<Content>: View where Content: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            content()
                .transition(.opacity)
        }
    }
}
