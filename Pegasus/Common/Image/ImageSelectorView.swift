import SwiftUI

struct ImageSelectorView<Label>: View where Label: View {
    @State var showingImagePicker = false
    @State private var inputImage: UIImage?
    let label: Label
    let onDimissHandler: (UIImage?) -> Void
    var body: some View {
        Button(action: {
            self.showingImagePicker = true
        }){
            self.label
        }.sheet(isPresented: $showingImagePicker,
                onDismiss: {
            self.onDimissHandler(self.inputImage)
        }) {
            ImagePicker(image: self.$inputImage)
        }
    }
}
struct WrapperView: View {
    @State var capturedImage: Image?
    var body: some View {
        VStack {
            Spacer()
            if capturedImage == nil {
                ImageSelectorView(label:
                                    Image(systemName: "photo.circle.fill")
                                    .font(.system(size: 155, weight:  .light))
                                    .foregroundColor(Color.black)) { img in
                    capturedImage = Image(uiImage: img!)
                }
            } else {
                capturedImage!
                    .resizable()
                    .frame(height: 350, alignment: .center)
                Divider()
                Button {
                    self.capturedImage = nil
                } label: {
                    Text("Reset")
                }
            }
            Spacer()
        }
    }
}
struct ImageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            WrapperView()
        }
    }
}
