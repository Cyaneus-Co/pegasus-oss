import SwiftUI
import ComposableArchitecture

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct TextFieldView: View {
    static let errorHighlightColor: Color = Color.red.lighter(by: 20)
    let store: StoreOf<TextFieldFeature>
    var autoCapitalize = false
    var autoComplete = false
    
    var body: some View {
        WithViewStore(self.store) {viewStore in
            HStack {
                img(viewStore)
                    .foregroundColor(Color(.systemPink))
                
                field(viewStore)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
        }
    }

    func field(_ viewStore: ViewStoreOf<TextFieldFeature>) -> some View {
        if viewStore.secure {
            return SecureField(viewStore.state.placeholder,
                               text: viewStore.binding(\.$rawValue))
                .foregroundColor(Color.black)
                .background(bgColor(viewStore))
                .autocapitalization(self.autoCapitalize ? .words : .none)
                .disableAutocorrection(!self.autoComplete)
                .eraseToAnyView()
        } else {
            return TextField(viewStore.state.placeholder,
                             text: viewStore.binding(\.$rawValue))
                .foregroundColor(Color.black)
                .background(bgColor(viewStore))
                .autocapitalization(self.autoCapitalize ? .words : .none)
                .disableAutocorrection(!self.autoComplete)
                .eraseToAnyView()
        }
    }
    
    func img(_ viewStore: ViewStoreOf<TextFieldFeature>) -> some View {
        return Image(systemName: viewStore.state.imageName)
            .foregroundColor(viewStore.state.isValid ? .primary : Self.errorHighlightColor)
    }
    func bgColor(_ viewStore: ViewStoreOf<TextFieldFeature>) -> Color {
        return viewStore.state.isValid ? .white : Self.errorHighlightColor
    }
}


func testStore() -> StoreOf<TextFieldFeature> {
    return Store(
        initialState: TextFieldFeature.State(
            id: UUID(),
            rawValue: "",
            isValid: true,
            placeholder: "something",
            imageName: "drop"),
        reducer: TextFieldFeature())
}

struct ValidatedTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            VStack {
                Spacer()
                TextFieldView(store: testStore())
                TextFieldView(store: testStore())
                TextFieldView(store: testStore())
                TextFieldView(store: testStore())
                Spacer()
            }
        }
    }
}
