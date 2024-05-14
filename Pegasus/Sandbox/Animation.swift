//
//  Animation.swift
//  Pegasus
//
//  Created by Jasper Mayone on 1/11/22.
//

import SwiftUI

struct Animation: View {
    
    @State private var showDetail = false
    
    var body: some View {
        VStack {
            if showDetail {
                Rectangle()
                    .frame(width: 200, height: 100, alignment: .center)
            } else {
                Circle()
                    .frame(width: 200, height: 100, alignment: .center)
            }
            Button {
                withAnimation(.interactiveSpring(response: 2.15, dampingFraction: 2.86, blendDuration: 5.25)) {
                    showDetail.toggle()
                }
            } label: {
                Text("Click Me!")
                    .foregroundColor(.black)
            }
        }
    }
}

struct Animation_Previews: PreviewProvider {
    static var previews: some View {
        Animation()
    }
}
