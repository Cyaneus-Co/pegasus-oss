import SwiftUI
import ComposableArchitecture
import NavigationStack

struct CreateAccountView: View {
    let store: StoreOf<OnBoardingFeature>

    // TODO: no environments mean no automatic binding here?
    @EnvironmentObject var userStore: UserStore
    var body: some View {
        WithViewStore(self.store) {viewStore in
            VStack {
                VStack {
                    Text("Welcome!")
                        .font(.system(size: 50, weight:  .medium))
                        .foregroundColor(.white)
                    Text("Please Create Your Account Below.")
                        .font(.system(size: 20, weight:  .light))
                        .foregroundColor(.white)
                }
                Section {
                    ForEachStore(
                        self.store.scope(
                            state: \.fields,
                            action: OnBoardingFeature.Action.field(id:action:))
                    ) { textFieldStore in
                        TextFieldView(store: textFieldStore)
                    }
                }
                
                if (viewStore.formState != .valid) {
                    // message tray
                    HStack {
                        if (viewStore.errorMessage == nil) {
                            ErrorMessageView(fgColor: .green,
                                             imageName: "info.circle",
                                             message: "Enter account details")
                        } else {
                            ErrorMessageView(fgColor: .red,
                                             imageName: "exclamationmark.octagon",
                                             message: "\(viewStore.errorMessage ?? "Oops")")
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewStore.send(.createButtonClicked)
                        }) {
                            HStack {
                                Text("Create Account")
                                    .fontWeight(.light)
                            }
                        }.buttonStyle(PegasusButtonStyle())
                            .padding()
                        Spacer()
                    }
                }
            }
        }
    }

    func buttonColor(_ isValid: Bool) -> Color {
        return isValid ? .white : .gray
    }
}
struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let store = StoreOf<OnBoardingFeature> (
            initialState: OnBoardingFeature.State(),
            reducer: OnBoardingFeature(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()))
        Screen {
            CreateAccountView(store: store).environmentObject(UserStore.shared)
        }
    }
}
