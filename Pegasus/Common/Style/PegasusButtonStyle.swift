import SwiftUI

struct PegasusButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    var DarkModeColor: [Color] = [.white, .black, .white]
    var LightModeColor: [Color] = [.black, .white, .black]
    var buttonWidth: CGFloat = 280
    var buttonHeight: CGFloat = 20
    
    public func makeBody(configuration: PegasusButtonStyle.Configuration) -> some View {
        return configuration.label
            .frame(width: buttonWidth, height: buttonHeight, alignment: .center)
            .font(.title)
            .padding()
            .background(bg())
            .cornerRadius(40)
            .foregroundColor(fg())
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(sg(), lineWidth: 5)
            )
    }
    
    private func bg () -> Color {
        return colorScheme == .light ? DarkModeColor[0] : LightModeColor[0]
    }
    
    private func fg () -> Color {
        return colorScheme == .light ? DarkModeColor[1] : LightModeColor[1]
    }
    
    private func sg () -> Color {
        return colorScheme == .light ? DarkModeColor[2] : LightModeColor[2]
    }
}


struct PegasusButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            VStack{
                Button(action: {}) {
                    Text("Click Me")
                        .fontWeight(.bold)
                }.buttonStyle(PegasusButtonStyle())
            }
        }
    }
}
