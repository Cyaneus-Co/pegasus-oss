import SwiftUI

struct ErrorMessageView: View {
    var fgColor: Color
    var imageName: String
    var message: String
    
    var body: some View {
        ZStack {
            Button(action: {}) {
                HStack {
                    Image(systemName: self.imageName)
                    Text(self.message)
                    Spacer()
                }
                .frame(width: 320)
                .padding(15)
                .background(Color.white)
                .foregroundColor(self.fgColor)
                .cornerRadius(20)
            }
            .disabled(true)
            .padding(.vertical, 10)
        }
    }
}

struct ErrorMessageView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            VStack {
                ErrorMessageView(fgColor: .green,
                                 imageName: "info.circle",
                                 message: "Enter account details")
                ErrorMessageView(fgColor: .red,
                                 imageName: "exclamationmark.octagon",
                                 message: "Password must be longer")
            }
        }
    }
}
