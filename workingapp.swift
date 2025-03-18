//
//import SwiftUI
//import LocalAuthentication
//
//
//struct ContentView: View {
//    @State private var isAuthenticated = false
//    @State private var userID = "" // This will hold the NBK of the authenticated user
//    @State private var users: [String: (String, String, String, String, String, String)] = [:]
//    @State private var message = ""
//    @State private var showAnniversaryPopup = false
//    @State private var anniversaryMessage = ""
//    @State private var showBirthdayPopup = false
//    
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                // Login Page (Bofa1 Logo with Face ID / Passcode Button)
//                if !isAuthenticated {
//                    VStack {
//                        Spacer()
//                        
//                        // Bofa1 Logo (before authentication)
//                        Image("BofA1")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.2)
//                        
//                        if !message.isEmpty {
//                            Text(message)
//                                .font(.footnote)
//                                .foregroundColor(.red)
//                                .padding(.bottom, 20)
//                                .multilineTextAlignment(.center)
//                        }
//                        
//                        Spacer()
//                        
//                        // Button to trigger Face ID / Passcode authentication
//                        Button(action: {
//                            autoAuthenticate()
//                        }) {
//                            Text("Face ID / Passcode")
//                                .font(.system(size: 14))
//                                .frame(maxWidth: .infinity)
//                                .padding(12)
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(8)
//                        }
//                        .frame(width: geometry.size.width * 0.5)
//                        .padding(.bottom, 20)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                } else {
//                    // If the user is authenticated, show the second page (Bofa2 logo and user details)
//                    VStack(spacing: 10) {
//                        // Bofa2 Logo (after authentication)
//                        Image("BofA2")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geometry.size.width)
//                            .padding(.top, 10)
//                        
//                        Spacer()
//                        
//                        // Profile Image of User
//                        getProfileImage(for: userID)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: geometry.size.width * 0.60, height: geometry.size.width * 0.6)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.red, lineWidth: 3))
//                            .shadow(radius: 5)
//                            .scaleEffect(0.9)
//                            .offset(y: -5)
//                        
//                        // User Info
//                        if let user = users[userID] {
//                            Text("\(user.0) \(user.1)")
//                                .font(.title)
//                                .fontWeight(.bold)
//                                .multilineTextAlignment(.center)
//                        } else {
//                            Text("Unknown User")
//                                .font(.title)
//                                .fontWeight(.bold)
//                                .multilineTextAlignment(.center)
//                        }
//                        
//                        VStack(spacing: 8) {
//                            if let user = users[userID] {
//                                   Text("NAME: \(user.0) \(user.1)") // Concatenate first name and last name
//                                       .font(.subheadline)
//                                       .fontWeight(.bold) // Make the name bold
//                                       .foregroundColor(.gray)
//                               } else {
//                                   Text("NAME: Unknown") // Fallback if user is not found
//                                       .font(.subheadline)
//                                       .fontWeight(.bold) // Make the name bold
//                                       .foregroundColor(.gray)
//                               }
//                               
//                               // Displaying other user details
//                               Text("ID: \(userID)")
//                                   .font(.subheadline)
//                                   .fontWeight(.bold) // Make the ID bold
//                                   .foregroundColor(.gray)
//
//                               Text("LOCATION: \(users[userID]?.2 ?? "Unknown")")
//                                   .font(.subheadline)
//                                   .fontWeight(.bold) // Make the location bold
//                                   .foregroundColor(.gray)
//
//                               Text("START DATE: \(users[userID]?.4 ?? "Unknown")")
//                                   .font(.subheadline)
//                                   .fontWeight(.bold) // Make the start date bold
//                                   .foregroundColor(.gray)
//                           }
//                        .padding(.horizontal, 20)
//                        
//                        Spacer()
//                        Spacer()
//                        // Scanning Icon (Radio waves)--FIND SOMETHING BETTER
//                        ZStack {
//                            // Celebration effects (fireworks, balloons, etc.)
//                            ZStack {
//                                if showAnniversaryPopup {
//                                    AnniversaryCelebrationView(anniversaryMessage: anniversaryMessage)
//                                        .transition(.opacity)
//                                        .onAppear {
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                                showAnniversaryPopup = false
//                                            }
//                                        }
//                                }
//                                
//                                if showBirthdayPopup {
//                                    BirthdayCelebrationView()
//                                        .transition(.opacity)
//                                        .onAppear {
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                                showBirthdayPopup = false
//                                            }
//                                        }
//                                }
//                            }
//                            .zIndex(1) // Higher zIndex for celebration effects to appear on top
//                            
//                            // NFC Image (Radio waves)
//                            Image("nfc") // Try "nfc.wave" or "nfc.tag"
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 120, height: 120)
//                                .foregroundColor(.red)
//                                .padding()
//                                .zIndex(0) // Lower zIndex for the NFC image to be behind the celebration effects
//                        }
//                        
//                        
//                        Spacer()
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                    .background(Color.white)
//                    .cornerRadius(12)
//                }
//            }
//            .onAppear(perform: loadUsersFromCSV)
//        }
//    }
//    
//    // Handles Biometric and Passcode Authentication
//    func autoAuthenticate() {
//        let context = LAContext()
//        var error: NSError?
//        
//        let reason = "Authenticate to access your ID card."
//        
//        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
//            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
//                DispatchQueue.main.async {
//                    if success {
//                        handleAuthenticationSuccess()
//                    } else {
//                        message = "Authentication Failed. Please try again."
//                    }
//                }
//            }
//        } else {
//            message = "Biometric Authentication not available on this device."
//        }
//    }
//    
//    // Matches the NBK with the logged-in user
//    func handleAuthenticationSuccess() {
//        let enteredNBK = promptForAuthCode() // Get NBK from user
//        
//        if let matchedUser = users[enteredNBK] {
//            userID = enteredNBK
//            isAuthenticated = true
//            message = "Authentication Successful! Welcome, \(matchedUser.0) \(matchedUser.1)."
//            
//            let startDate = matchedUser.4
//            let birthday = matchedUser.5
//
//            // Check for Work Anniversary
//            if isWorkAnniversary(for: startDate), let years = yearsWorked(from: startDate) {
//                anniversaryMessage = "Happy \(years) Year Work Anniversary! 🏦🎉"
//                showAnniversaryPopup = true
//            }
//
//
//
//                   // Check for Birthday
//                   showBirthdayPopup = isBirthday(for: birthday)
//               } else {
//                   isAuthenticated = false
//                   message = "Authentication Failed. Try Again."
//               }
//           }
//    
//    // Simulate user entering NBK (Replace with actual input method)
//    func promptForAuthCode() -> String {
//        //return "ZK23903" // Example NBK (Replace with dynamic input)
//       return "ZK12345" //mahender
//    }
//    
//    // Load Users from CSV
//    func loadUsersFromCSV() {
//        if let filePath = Bundle.main.path(forResource: "Bofa Associates", ofType: "csv") {
//            do {
//                let content = try String(contentsOfFile: filePath, encoding: .utf8)
//                let rows = content.components(separatedBy: "\n").dropFirst()
//                for row in rows {
//                    let columns = row.components(separatedBy: ",")
//                    if columns.count >= 7 {
//                        let nbk = columns[0].trimmingCharacters(in: .whitespaces)
//                        let fname = columns[1].trimmingCharacters(in: .whitespaces)
//                        let lname = columns[2].trimmingCharacters(in: .whitespaces)
//                        let location = columns[3].trimmingCharacters(in: .whitespaces)
//                        let status = columns[4].trimmingCharacters(in: .whitespaces)
//                        let sdate = columns[5].trimmingCharacters(in: .whitespaces)
//                        let bday = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
//                        users[nbk] = (fname, lname, location, status, sdate, bday)
//                    }
//                    
//                }
//                print(users)
//            } catch {
//                print("Error reading CSV file: \(error.localizedDescription)")
//                
//            }
//        }
//    }
//    
//    
//    func isWorkAnniversary(for startDate: String) -> Bool {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        if let startDate = dateFormatter.date(from: startDate) {
//            let calendar = Calendar.current
//            let today = Date()
//            
//            let startMonth = calendar.component(.month, from: startDate)
//            let startDay = calendar.component(.day, from: startDate)
//            
//            let todayMonth = calendar.component(.month, from: today)
//            let todayDay = calendar.component(.day, from: today)
//            
//            return startMonth == todayMonth && startDay == todayDay
//        }
//        return false
//    }
//    func yearsWorked(from startDate: String) -> Int? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        if let startDate = dateFormatter.date(from: startDate) {
//            let calendar = Calendar.current
//            let today = Date()
//            
//            let components = calendar.dateComponents([.year], from: startDate, to: today)
//            return components.year
//        }
//        return nil
//    }
//    
//    
//    struct AnniversaryCelebrationView: View {
//        @State private var animate = false
//        var anniversaryMessage: String
//
//        var body: some View {
//            ZStack {
//                // Fireworks Effect - Starburst Animation
//                ForEach(0..<10, id: \.self) { _ in
//                              StarburstEffect(animate: $animate)
//                                  .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -250...250))
//                                  .opacity(animate ? 0 : 1)
//                                  .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(Double.random(in: 0.2...1.0)))
//                          }
//               //circle --NOT SURE IF I WANT TO KEEP
//                ForEach(0..<5, id: \.self) { i in
//                               Circle()
//                                   .foregroundColor([.red, .blue, .green, .yellow, .purple].randomElement()!)
//                                   .frame(width: CGFloat(Int.random(in: 30...60)), height: CGFloat(Int.random(in: 30...60)))
//                                   .offset(x: CGFloat(Int.random(in: -100...100)), y: animate ? -300 : 300)
//                                   .opacity(animate ? 0 : 1)
//                                   .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.3))
//                           }
//                // Anniversary Message
//                VStack {
//                    Text(anniversaryMessage)
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.blue)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                }
//                .shadow(radius: 10)
//            }
//            .onAppear {
//                animate = true
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.white)
//        }
//    }
//
//    struct StarburstEffect: View {
//        @Binding var animate: Bool // Bind to the parent view's animate state
//
//        var body: some View {
//            ZStack {
//                // Simulate Firework Burst with multiple lines
//                ForEach(0..<12, id: \.self) { i in
//                    Rectangle()
//                        .frame(width: 2, height: CGFloat(Int.random(in: 50...120)))
//                        .rotationEffect(.degrees(Double(i) * 30)) // Spread out the burst
//                        .foregroundColor([.red, .blue, .green, .yellow, .purple].randomElement()!)
//                        .opacity(0.8)
//                        .offset(x: 0, y: 0)
//                }
//            }
//            .scaleEffect(animate ? 1.5 : 0.5)  // Explosion animation scale
//            .animation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: true))
//        }
//    }
//
//
//
//    
//    func isBirthday(for birthday: String) -> Bool {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        if let birthDate = dateFormatter.date(from: birthday) {
//            let calendar = Calendar.current
//            let today = Date()
//            
//            let birthMonth = calendar.component(.month, from: birthDate)
//            let birthDay = calendar.component(.day, from: birthDate)
//            
//            let todayMonth = calendar.component(.month, from: today)
//            let todayDay = calendar.component(.day, from: today)
//            
//            print("Birthdate: \(birthMonth)/\(birthDay) - Today's date: \(todayMonth)/\(todayDay)")  // Debugging output
//            
//            return birthMonth == todayMonth && birthDay == todayDay
//        }
//        return false
//    }
//    
//    
//    struct BirthdayCelebrationView: View {
//        @State private var animate = false
//        
//        var body: some View {
//            ZStack {
//                // Confetti Effect
//                ForEach(0..<10, id: \.self) { i in
//                    Circle()
//                        .foregroundColor([.red, .blue, .green, .yellow, .purple, .pink].randomElement()!)
//                        .frame(width: CGFloat(Int.random(in: 20...50)), height: CGFloat(Int.random(in: 20...50)))
//                        .offset(x: CGFloat(Int.random(in: -150...150)), y: animate ? -400 : 400)
//                        .opacity(animate ? 0 : 1)
//                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.2))
//                }
//                
//                // Balloons
//                ForEach(0..<5, id: \.self) { i in
//                    Image(systemName: "balloon.fill")
//                        .resizable()
//                        .foregroundColor([.red, .blue, .green, .yellow, .purple].randomElement()!)
//                        .frame(width: 60, height: 100)
//                        .offset(x: CGFloat(Int.random(in: -100...100)), y: animate ? -300 : 300)
//                        .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: false).delay(Double(i) * 0.5))
//                }
//                
//                // Birthday Message
//                VStack {
//                    Text("🎉 Happy Birthday! 🎂🎈")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundColor(.blue)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                    
//                }
//                .shadow(radius: 10)
//            }
//            .onAppear {
//                animate = true
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.white)
//        }
//    }
//    
//    
//    // Retrieve the profile image based on the userID
//    func getProfileImage(for id: String) -> Image {
//        switch id {
//        case "ZK23903":
//            return Image("ID_Sadia")
//        case "ZK12345":
//            return Image("ID_Mahender")
//        case "ZK77565":
//            return Image(systemName: "person.3.fill")
//        default:
//            return Image(systemName: "person.crop.square")
//        }
//    }
//    
//    
//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            ContentView()
//        }
//    }
//    
//}
