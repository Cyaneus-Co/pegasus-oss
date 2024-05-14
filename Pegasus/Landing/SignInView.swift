import SwiftUI
import ComposableArchitecture

struct SignInView: View {

    let store: StoreOf<UserAuthFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(viewStore.signInMessage)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight:  .light))
                Button {
                    viewStore.send(.signInTapped)
                } label: {
                    HStack {
                        Text("Sign In")
                            .fontWeight(.light)
                    }
                }.buttonStyle(PegasusButtonStyle(buttonWidth: 100, buttonHeight: 5))
            }
        }
    }
}
