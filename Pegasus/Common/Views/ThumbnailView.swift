import SwiftUI

enum ClipShape {
    case circle
    case roundedRectangle
}

struct ThumbnailView: View {
    var image: UIImage
    var size: CGFloat = 75
    var clipShape: ClipShape = .circle
    var color: Color = .white
    
    init(_ image: UIImage) {
        self.image = image
    }
    
    init(image: UIImage, size: CGFloat, clipShape: ClipShape, color: Color) {
        self.image = image
        self.size = size
        self.clipShape = clipShape
        self.color = color
    }
    init(_ imagePath: String) {
        self.image = UIImage(named: imagePath)!
    }
    init(imagePath: String, size: CGFloat) {
        self.init(imagePath)
        self.size = size
    }
    func clipShapeView(_ thumbnail: Image) -> some View {
        switch self.clipShape {
        case .circle:
            return thumbnail
                .resizable()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(color, lineWidth: 3))
                .shadow(radius: 2)
                .eraseToAnyView()
        case .roundedRectangle:
            return thumbnail
                .resizable()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))                .eraseToAnyView()
        }
    }
    var body: some View {
        clipShapeView(Image(uiImage: self.image))
    }
}
struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            VStack {
                Spacer()
                ThumbnailView("tree")
                Spacer()
                ThumbnailView(
                    image: UIImage(named: "tree")!,
                    size: 225,
                    clipShape: .roundedRectangle,
                    color: .black
                )
                Spacer()
                
            }
        }
    }
}
