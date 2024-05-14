import ComposableArchitecture
import SwiftUI

/*
 
 MainState
 - routing state
 
 \
 FeatureState
 - feature state
 - routing state
 \
 Child State
 - child state
 
 - Main state is the app state
 - feature state needs to update routing state
 - feature needs to support child store
 - app should route
 */





struct MainEnvironment {}

struct Main : ReducerProtocol {
    struct State: Equatable {
        var theme = "dark"
        var description = "<enter something>"
    }

    enum Action: Equatable {
        case toggleTheme
        case clickMeTapped
        case descriptionUpdated(String)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .descriptionUpdated(desc):
            state.description = desc
            return .none
        case .toggleTheme:
            if state.theme == "dark" {
                state.theme = "light"
            } else {
                state.theme = "dark"
            }
            return .none
        case .clickMeTapped:
            return Effect(value: withAnimation {
                .toggleTheme
            })
        }
    }
}

struct MainView: View {
    let store: StoreOf<Main>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TextField("Description",
                          text: viewStore.binding(
                            get: \.description,
                            send: { .descriptionUpdated($0) }))
                Spacer()
                HStack {
                    Spacer()
                    Button {
//                        withAnimation {
//                            viewStore.send(MainAction.toggleTheme)
//                        }
                    } label: {
                        Image(systemName: "togglepower")
                            .font(.largeTitle)
                            .foregroundColor(viewStore.theme == "dark" ? Color.white : Color.black)
                    }
                    Spacer()
                }
                Spacer()
                Circle()
                    .frame(width: 200, height: 100, alignment: .center)
                    .scaleEffect(viewStore.theme == "dark" ? 2 : 1)
                    .foregroundColor(viewStore.theme == "dark" ? .red : .yellow)
                Spacer()
                Button {
//                    withAnimation(.linear) {
//                        viewStore.send(MainAction.clickMeTapped)
//                    }
                } label: {
                    Text("Click Me!")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                }
                Spacer()
            }
            .padding()
            .background(viewStore.theme == "dark" ? Color.blue : Color.white)
        }
    }
}

struct ContainerView: View {
    
    let store: StoreOf<Main>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            
            if viewStore.theme == "dark" {
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(width: 200, height: 100, alignment: .center)
            } else {
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 200, height: 100, alignment: .center)
            }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            store: StoreOf<Main>(
                initialState: Main.State(), reducer: Main()))
    }
}
