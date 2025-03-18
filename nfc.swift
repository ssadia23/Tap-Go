//import SwiftUI
//import LocalAuthentication
//import CoreNFC
//
//struct ContentView: View {
//    @State private var isAuthenticated = false
//    @State private var userID = ""
//    @State private var users: [String: (String, String, String, String, String)] = [:]
//    @State private var message = ""
//    private var nfcManager = NFCManager()
//
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                if !isAuthenticated {
//                    VStack {
//                        Spacer()
//                        
//                        // Bank of America logo
//                        Image("BofA1")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.2)
//                        
//                        // Error/Message display
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
//                        // Face ID / Passcode Button
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
//                } else {
//                    VStack(spacing: 10) {
//                        // Profile Image and user data
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
//                            Text("ID: \(userID)")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            Text("Location: \(users[userID]?.2 ?? "Unknown")")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            
//                            Text("Started on: \(users[userID]?.4 ?? "Unknown")")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.horizontal, 20)
//                        
//                        Spacer()
//
//                        // NFC Scan Button
//                        Button(action: {
//                            nfcManager.startNFCSession { scannedID in
//                                if let matchedUser = users[scannedID] {
//                                    userID = scannedID
//                                    isAuthenticated = true
//                                    message = "Access Granted: \(matchedUser.0) \(matchedUser.1)"
//                                } else {
//                                    message = "Access Denied: Badge Not Recognized"
//                                }
//                            }
//                        }) {
//                            VStack {
//                                Image(systemName: "antenna.radiowaves.left.and.right")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 100, height: 100)
//                                    .foregroundColor(.red)
//                                
//                                Text("Tap to Scan NFC Badge")
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                        .padding(.top, 20)
//
//                        Spacer()
//                    }
//                    .padding(.horizontal, 20)
//                }
//            }
//            .onAppear(perform: loadUsersFromCSV)
//        }
//    }
//
//    func autoAuthenticate() {
//        let context = LAContext()
//        var error: NSError?
//
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to use the app") { success, authenticationError in
//                DispatchQueue.main.async {
//                    if success {
//                        // Set userID after successful Face ID authentication
//                        // Here we can set the userID explicitly, e.g., for now, assuming "ZK23903" as a test user
//                        userID = "ZK23903"  // Replace with actual logic to map Face ID to a user
//                        isAuthenticated = true
//                    } else {
//                        message = "Authentication Failed"
//                    }
//                }
//            }
//        } else {
//            message = "Face ID / Touch ID not available"
//        }
//    }
//
//
//    // Matches the NBK with the logged-in user
//    func handleAuthenticationSuccess() {
//        let enteredNBK = promptForAuthCode() // Get NBK from user
//        
//        if let matchedUser = users[enteredNBK] {
//            userID = enteredNBK
//            isAuthenticated = true
//            message = "Authentication Successful! Welcome, \(matchedUser.0) \(matchedUser.1)."
//        } else {
//            isAuthenticated = false
//            message = "Authentication Failed. Try Again."
//        }
//    }
//    
//    // Simulate user entering NBK (Replace with actual input method)
//    func promptForAuthCode() -> String {
//        return "ZK23903" // Example NBK (Replace with dynamic input)
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
//                    if columns.count >= 6 {
//                        let nbk = columns[0].trimmingCharacters(in: .whitespaces)
//                        let fname = columns[1].trimmingCharacters(in: .whitespaces)
//                        let lname = columns[2].trimmingCharacters(in: .whitespaces)
//                        let location = columns[3].trimmingCharacters(in: .whitespaces)
//                        let status = columns[4].trimmingCharacters(in: .whitespaces)
//                        let sdate = columns[5].trimmingCharacters(in: .whitespaces)
//                        users[nbk] = (fname, lname, location, status, sdate)
//                    }
//                }
//            } catch {
//                print("Error reading CSV file: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    func getProfileImage(for id: String) -> Image {
//        switch id {
//        case "ZK23903":
//            return Image("ID_Sadia")
//        case "ZK12345":
//            return Image(systemName: "person.2.fill")
//        case "ZK98981":
//            return Image(systemName: "person.3.fill")
//        default:
//            return Image(systemName: "person.crop.square")
//        }
//    }
//}
//
//// NFCManager as a class to handle NFC reading
//class NFCManager: NSObject, NFCNDEFReaderSessionDelegate {
//    private var nfcSession: NFCNDEFReaderSession?
//    private var onScanComplete: ((String) -> Void)?
//
//    func startNFCSession(completion: @escaping (String) -> Void) {
//        onScanComplete = completion
//        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
//        nfcSession?.alertMessage = "Hold your NFC badge near the reader."
//        nfcSession?.begin()
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        print("NFC Session Ended: \(error.localizedDescription)")
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        if let record = messages.first?.records.first,
//           let payload = String(data: record.payload, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
//            DispatchQueue.main.async {
//                self.onScanComplete?(payload)
//            }
//        }
//    }
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
