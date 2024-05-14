import SwiftUI
import ComposableArchitecture

struct AddAvatarView: View {
    let store: StoreOf<OnBoardingFeature>
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Spacer()
                ZStack {
                    HStack{
                        Spacer()
                        selectAvatar(viewStore: viewStore)
                        Spacer()
                    }
                    .padding(.vertical)
                }
                Spacer()
            }
            .background(Color("Main"))
            .navigationBarTitle("Instafilter")
        }
    }
    
    func selectAvatar(viewStore: ViewStoreOf<OnBoardingFeature>) -> some View {
        if viewStore.state.profile.avatar != nil {
            return VStack {
                Image(uiImage: viewStore.state.profile.avatar!)
                    .resizable()
                    .frame(width: 280, height: 280)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .shadow(radius: 2)
                
                HStack {
                    Text("Use this as your profile picture?")
                        .font(.system(size: 30, weight:  .light))
                }
                .padding(.top)
                .padding(.bottom)
                
                HStack {
                    VStack {
                        Button {
                            viewStore.send(.avatarRejected)
                        }
                    label: {
                        StyledLabel(text: "No",
                                    imageName: "trash.fill",
                                    backgroundColor: Color.red)
                    }
                    }
                    Spacer()
                    VStack {
                        Button {
                            viewStore.send(.avatarAccepted)
                        }
                    label: {
                        StyledLabel(text: "Yes",
                                    imageName: "photo.fill",
                                    backgroundColor: Color.green)
                    }
                    }
                }.padding(.horizontal)
            }.eraseToAnyView()
            
        } else {
            return VStack {
                Button(action: {
                    self.showingImagePicker = true
                }){
                    Text("Select a profile picture")
                }.sheet(isPresented: $showingImagePicker,
                        onDismiss: {
                    viewStore.send(.imageSelected(self.inputImage))
                }) {
                    ImagePicker(image: self.$inputImage)
                }
                .buttonStyle(PegasusButtonStyle())
            }.eraseToAnyView()
        }
    }
}

struct AddAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        let store = StoreOf<OnBoardingFeature>(
            initialState: OnBoardingFeature.State(),
            reducer: OnBoardingFeature(mainQueue: DispatchQueue.main.eraseToAnyScheduler()))
        Screen {
            AddAvatarView(store: store)
        }
    }
}
