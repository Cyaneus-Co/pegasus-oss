import SwiftUI

struct CirclesView: View {
  
  private var circleColor = Color(UIColor.systemGray)
  
  var body: some View {
    VStack() {
      // With ZStack
      ZStack {
        Circle()
          .stroke(circleColor, lineWidth: 4)

        Text("13")
      }
      .frame(width: 40, height: 40)
      
      // Background
      Text("13")
        .padding()
        .background(
          Circle()
            .stroke(circleColor, lineWidth: 4)
            .padding(6)
        )
      
      // Overlay
      Text("13")
        .padding()
        .overlay(
          Circle()
            .stroke(circleColor, lineWidth: 4)
            .padding(6)
        )

      // Fill circle usig cliped shape
      Text("13")
        .padding()
        .background(circleColor)
        .clipShape(Circle())
    }
  }
}

struct CirclesView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      CirclesView()
      CirclesView()
        .preferredColorScheme(.dark)
    }
  }
}

