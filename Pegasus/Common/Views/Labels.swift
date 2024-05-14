import SwiftUI

struct StyledLabel: View {
    var text: String
    var imageName: String
    var backgroundColor: Color
    var width: CGFloat = 120
    var font: Font = .largeTitle
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(font)
            Text(text)
                .fontWeight(.semibold)
                .font(font)
        }
        .frame(width: width)
        .padding()
        .foregroundColor(.white)
        .background(backgroundColor)
        .cornerRadius(15)
    }
}

struct Labels_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            VStack {
                StyledLabel(text: "Yes",
                            imageName: "photo.circle.fill",
                            backgroundColor: Color.green)
                StyledLabel(text: "No",
                            imageName: "trash.circle.fill",
                            backgroundColor: Color.red)
                StyledLabel(text: "Maybe",
                            imageName: "questionmark.circle.fill",
                            backgroundColor: Color.yellow,
                            width: 180)
                StyledLabel(text: "Smaller",
                            imageName: "arrow.down",
                            backgroundColor: Color.blue,
                            font: .footnote)
            }
        }
    }
}
