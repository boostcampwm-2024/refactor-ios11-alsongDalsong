import ASEncoder
import ASEntity
import Foundation
@preconcurrency internal import FirebaseAuth
@preconcurrency internal import FirebaseDatabase

public final class ASFirebaseAuth: ASFirebaseAuthProtocol {
    public static var myID: String?
    private let databaseRef = Database.database().reference()

    public func signIn(nickname: String, avatarURL: URL?) async throws {
        do {
            guard let myID = ASFirebaseAuth.myID else {
                throw ASNetworkErrors(type: .firebaseSignIn, reason: "ASFirebaseAuth.myID is nil", file: #file, line: #line)
            }
            let player = Player(id: myID, avatarUrl: avatarURL, nickname: nickname, order: 0)
            let playerData = try ASEncoder.encode(player)
            let dict = try JSONSerialization.jsonObject(with: playerData, options: .allowFragments) as? [String: Any]
            let userStatusRef = databaseRef.child("players").child(myID)
            userStatusRef.keepSynced(true)
            let connectedRef = databaseRef.child(".info/connected")
            connectedRef.observe(.value) { snapshot in
                guard let isConnected = snapshot.value as? Bool else { return }
                if isConnected {
                    userStatusRef.setValue(dict)
                }
            }
        } catch {
            throw ASNetworkErrors(type: .firebaseSignIn, reason: error.localizedDescription, file: #file, line: #line)
        }
    }

    public func signOut() async throws {
        do {
            guard let userID = ASFirebaseAuth.myID else {
                throw ASNetworkErrors(type: .firebaseSignOut, reason: "ASFirebaseAuth.myID is nil", file: #file, line: #line)
            }
            try await databaseRef.child("players").child(userID).removeValue()
            try Auth.auth().signOut()
        } catch {
            throw ASNetworkErrors(type: .firebaseSignOut, reason: error.localizedDescription, file: #file, line: #line)
        }
    }

    public static func configure() {
        if let uid = Auth.auth().currentUser?.uid {
            ASFirebaseAuth.myID = uid
        } else {
            Task {
                let authResult = try await Auth.auth().signInAnonymously()
                ASFirebaseAuth.myID = authResult.user.uid
            }
        }
    }
}
