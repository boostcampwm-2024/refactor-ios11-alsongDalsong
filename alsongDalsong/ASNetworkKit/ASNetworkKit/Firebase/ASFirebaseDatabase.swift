import ASEntity
import Combine
@preconcurrency internal import FirebaseFirestore

final class ASFirebaseDatabase: ASFirebaseDatabaseProtocol {
    private let firestoreRef = Firestore.firestore()
    private var roomListeners: ListenerRegistration?
    private var roomPublisher = PassthroughSubject<Room, Error>()
    
    func addRoomListener(roomNumber: String) -> AnyPublisher<Room, Error> {
        let roomRef = firestoreRef.collection("rooms").document(roomNumber)
        let listener = roomRef.addSnapshotListener { documentSnapshot, error in
            if let error {
                return self.roomPublisher.send(completion: .failure(error))
            }
            
            guard let document = documentSnapshot, document.exists else {
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors(type: .firebaseListener, reason: error?.localizedDescription ?? "", file: #file, line: #line)))
            }
            
            do {
                let room = try document.data(as: Room.self)
                return self.roomPublisher.send(room)
            } catch {
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors(type: .firebaseListener, reason: error.localizedDescription, file: #file, line: #line)))
            }
        }
        
        roomListeners = listener
        return roomPublisher.eraseToAnyPublisher()
    }
    
    func removeRoomListener() {
        roomListeners?.remove()
    }
}
