import SwiftUI

struct ReferalVeiw: View {
    var body: some View {
        VStack{
            VStack {
                Text("Have.")
                    .foregroundColor(.white)
                    .font(.system(size: 55, weight:  .medium))
                    .underline()
                    .padding(.bottom)
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.secondary)
                    Text("Enter your username or email.")
                        .foregroundColor(Color.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                HStack {
                    Image(systemName: "key")
                        .foregroundColor(.secondary)
                    Text("Enter your password.")
                        .foregroundColor(Color.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }

            VStack{
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                    Text("Login")
                        .fontWeight(.bold)
                }.buttonStyle(OurButtonStyle())
                .padding(.top)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("PegasusSplash")
                        .resizable()
                        .aspectRatio(contentMode: .fill))
        .edgesIgnoringSafeArea(.all)
    }
}

struct ReferalVeiw_Previews: PreviewProvider {
    static var previews: some View {
        ReferalVeiw()
    }
}
