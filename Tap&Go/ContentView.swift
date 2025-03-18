
import SwiftUI
import LocalAuthentication


struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var userID = "" // This will hold the NBK of the authenticated user
    @State private var users: [String: (String, String, String, String, String, String)] = [:]
    @State private var message = ""
    @State private var showAnniversaryPopup = false
    @State private var anniversaryMessage = ""
    @State private var showBirthdayPopup = false


    var body: some View {
        ZStack {
            Image("Bofa_BG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                if !isAuthenticated {
                    Spacer()

                  //issue with alignment
                    if !message.isEmpty {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.bottom, 20)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    Button(action: {
                        autoAuthenticate()
                    }) {
                        Text("Face ID / Passcode")
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 40)
                    .frame(width: UIScreen.main.bounds.width * 0.6)
                }
                
                else {
                    VStack(spacing: 10) {
                        Image("BofA2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .scaleEffect(1.2)
                            .padding(.top, 5)

                        getProfileImage(for: userID)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width * 0.80, height: UIScreen.main.bounds.width * 0.8)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.red, lineWidth: 4))
                            .shadow(radius: 5)
                            .scaleEffect(0.95)
                            .offset(y: -5)
                       
                        VStack(spacing: 9) {
                            if let user = users[userID] {
                                Text("\(user.0) \(user.1)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            } else {
                                Text("NAME: Unknown")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                           }

                            Text("ID: \(userID)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            Text("LOCATION: \(users[userID]?.2 ?? "Unknown")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            Text("START DATE: \(users[userID]?.4 ?? "Unknown")")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)

                       // Spacer()

                        ZStack {
                            VStack {
                                  if showAnniversaryPopup {
                                      AnniversaryCelebrationView(anniversaryMessage: anniversaryMessage)
                                          .transition(.opacity)
                                          .onAppear {
                                              DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                  showAnniversaryPopup = false
                                              }
                                          }
                                  }

                                  if showBirthdayPopup {
                                      BirthdayCelebrationView()
                                          .transition(.opacity)
                                          .onAppear {
                                              DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                  showBirthdayPopup = false
                                              }
                                          }
                                  }
                              }
                              .zIndex(2)

                              Image("nfc")
                                  .resizable()
                                  .scaledToFit()
                                  .frame(width: 120, height: 120)
                                  .foregroundColor(.red)
                                  .padding()
                                  .zIndex(1)
                                  .offset(y: 40)
                          }
                          .zIndex(1)

                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear(perform: loadUsersFromCSV)

    }
    func autoAuthenticate() {
        let context = LAContext()
        var error: NSError?

        let reason = "Authenticate to access your ID card."

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        handleAuthenticationSuccess()
                    } else {
                        message = "Authentication Failed. Please try again."
                    }
                }
            }
        } else {
            message = "Biometric Authentication not available on this device."
        }
    }

    
    func handleAuthenticationSuccess() {
        let enteredNBK = promptForAuthCode()

        if let matchedUser = users[enteredNBK] {
            userID = enteredNBK
            isAuthenticated = true
            message = "Authentication Successful! Welcome, \(matchedUser.0) \(matchedUser.1)."

            let startDate = matchedUser.4
            let birthday = matchedUser.5

            if isWorkAnniversary(for: startDate), let years = yearsWorked(from: startDate) {
                anniversaryMessage = "Happy \(years) Year Work Anniversary! 🏦🎉"
                showAnniversaryPopup = true
            }

                   showBirthdayPopup = isBirthday(for: birthday)
               } else {
                   isAuthenticated = false
                   message = "Authentication Failed. Try Again."
               }
           }

    // Demo seleting nbk
    func promptForAuthCode() -> String {
       // return "ZK23903" //sadia
       return "ZK12345" //mahender
    }

    func loadUsersFromCSV() {
        if let filePath = Bundle.main.path(forResource: "Bofa Associates", ofType: "csv") {
            do {
                let content = try String(contentsOfFile: filePath, encoding: .utf8)
                let rows = content.components(separatedBy: "\n").dropFirst()
                for row in rows {
                    let columns = row.components(separatedBy: ",")
                    if columns.count >= 7 {
                        let nbk = columns[0].trimmingCharacters(in: .whitespaces)
                        let fname = columns[1].trimmingCharacters(in: .whitespaces)
                        let lname = columns[2].trimmingCharacters(in: .whitespaces)
                        let location = columns[3].trimmingCharacters(in: .whitespaces)
                        let status = columns[4].trimmingCharacters(in: .whitespaces)
                        let sdate = columns[5].trimmingCharacters(in: .whitespaces)
                        let bday = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
                        users[nbk] = (fname, lname, location, status, sdate, bday)
                    }

                }
                //print(users)
            } catch {
               // print("Error reading CSV file: \(error.localizedDescription)")

            }
        }
    }


    func isWorkAnniversary(for startDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        if let startDate = dateFormatter.date(from: startDate) {
            let calendar = Calendar.current
            let today = Date()

            let startMonth = calendar.component(.month, from: startDate)
            let startDay = calendar.component(.day, from: startDate)

            let todayMonth = calendar.component(.month, from: today)
            let todayDay = calendar.component(.day, from: today)

            return startMonth == todayMonth && startDay == todayDay
        }
        return false
    }
    func yearsWorked(from startDate: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        if let startDate = dateFormatter.date(from: startDate) {
            let calendar = Calendar.current
            let today = Date()

            let components = calendar.dateComponents([.year], from: startDate, to: today)
            return components.year
        }
        return nil
    }


    struct AnniversaryCelebrationView: View {
        @State private var animate = false
        var anniversaryMessage: String

        var body: some View {
            ZStack {
                // Fireworks Effect - Starburst Animation
                ForEach(0..<10, id: \.self) { _ in
                              StarburstEffect(animate: $animate)
                                  .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -250...250))
                                  .opacity(animate ? 0 : 1)
                                  .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(Double.random(in: 0.2...1.0)))
                          }
               //circle --NOT SURE IF I WANT TO KEEP
                ForEach(0..<5, id: \.self) { i in
                               Circle()
                                   .foregroundColor([.red, .blue, .green, .yellow, .purple].randomElement()!)
                                   .frame(width: CGFloat(Int.random(in: 30...60)), height: CGFloat(Int.random(in: 30...60)))
                                   .offset(x: CGFloat(Int.random(in: -100...100)), y: animate ? -300 : 300)
                                   .opacity(animate ? 0 : 1)
                                   .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.3))
                           }
                // Anniversary Message
                VStack {
                    Text(anniversaryMessage)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .shadow(radius: 10)
            }
            .onAppear {
                animate = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }

    struct StarburstEffect: View {
        @Binding var animate: Bool

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<12, id: \.self) { i in
                        Rectangle()
                            .frame(width: 2, height: CGFloat(Int.random(in: 50...120)))
                            .rotationEffect(.degrees(Double(i) * 30)) // Spread out the burst
                            .foregroundColor([.red, .blue, .green, .yellow, .purple].randomElement()!)
                            .opacity(0.8)
                            .position(
                                x: CGFloat.random(in: 0..<geometry.size.width),
                                y: animate ? CGFloat.random(in: -geometry.size.height...geometry.size.height) : -geometry.size.height
                            )
                    }
                }
                .scaleEffect(animate ? 1.5 : 0.5) // Explosion animation scale
                .animation(Animation.easeOut(duration: 2.5).repeatForever(autoreverses: true))
            }
        }
    }


    func isBirthday(for birthday: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        if let birthDate = dateFormatter.date(from: birthday) {
            let calendar = Calendar.current
            let today = Date()

            let birthMonth = calendar.component(.month, from: birthDate)
            let birthDay = calendar.component(.day, from: birthDate)

            let todayMonth = calendar.component(.month, from: today)
            let todayDay = calendar.component(.day, from: today)

        //    print("Birthdate: \(birthMonth)/\(birthDay) - Today's date: \(todayMonth)/\(todayDay)")

            return birthMonth == todayMonth && birthDay == todayDay
        }
        return false
    }


    struct BirthdayCelebrationView: View {
        @State private var animate = false

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Confetti
                    ForEach(0..<10, id: \.self) { i in
                        Circle()
                            .foregroundColor([.red, .blue, .green, .yellow, .purple, .pink].randomElement()!)
                            .frame(width: CGFloat(Int.random(in: 20...50)), height: CGFloat(Int.random(in: 20...50)))
                            .position(
                                x: CGFloat.random(in: 0..<geometry.size.width),
                                y: animate ? CGFloat.random(in: -geometry.size.height...geometry.size.height) : geometry.size.height + 400
                            ) // Randomize the position across the whole screen
                            .opacity(animate ? 0 : 1)
                            .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.2))
                    }

                    // Balloons
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: "balloon.fill")
                            .resizable()
                            .foregroundColor([.red, .blue, .green, .yellow, .purple].randomElement()!)
                            .frame(width: 60, height: 100)
                            .position(
                                x: CGFloat.random(in: 0..<geometry.size.width),
                                y: animate ? -300 : geometry.size.height + 300
                            ) // Randomize the position across the whole screen
                            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: false).delay(Double(i) * 0.5))
                    }

                    // Birthday Message
                    VStack {
                        Text("🎉 Happy Birthday! 🎂🎈")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .shadow(radius: 10)
                }
                .onAppear {
                    animate = true
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
    }

    func getProfileImage(for id: String) -> Image {
        switch id {
        case "ZK23903":
            return Image("ID_Sadia2")
        case "ZK12345":
            return Image("ID_Mahender")
        case "ZK77565":
            return Image(systemName: "person.3.fill")
        default:
            return Image(systemName: "person.crop.square")
        }
    }


    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

}
