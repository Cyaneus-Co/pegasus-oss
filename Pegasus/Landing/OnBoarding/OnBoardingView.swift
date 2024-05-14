import SwiftUI
import ComposableArchitecture
import NavigationStack

struct OnBoardingView: View {
    let store: StoreOf<OnBoardingFeature>

    var body: some View {
        VStack {
            WithViewStore(self.store) { viewStore in selectView(viewStore: viewStore)}
        }
    }

    func selectView(viewStore: ViewStoreOf<OnBoardingFeature>) -> some View {
        switch viewStore.state.currentStep {
        case .createAccount:
            return Screen {
                CreateAccountView(store: store).eraseToAnyView()
            }
        case .pickAvatar:
            return Screen {
                AddAvatarView(store: store).eraseToAnyView()
            }
        }
    }
}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        let store = StoreOf<OnBoardingFeature>(
            initialState: OnBoardingFeature.State(),
            reducer: OnBoardingFeature(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler())
        )
        OnBoardingView(store: store)
    }
}
