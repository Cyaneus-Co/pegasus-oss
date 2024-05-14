import SwiftUI

struct DividerView: View {
    
    var color: Color
    var width: CGFloat = Layout.contentWidth
    var height: CGFloat = 10
    
    var body: some View {
        RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
            .frame(width: width, height: height)
            .foregroundColor(color)
    }
}

struct DividerView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            VStack {
                Spacer()
                DividerView(color: .black)
                Spacer()
                DividerView(color: .white)
                Spacer()
            }
        }
    }
}
