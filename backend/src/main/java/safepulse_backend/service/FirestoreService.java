package safepulse_backend.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class FirestoreService {

    public List<Map<String, Object>> getEmergencyContacts(String userId)
            throws Exception {

        Firestore db = FirestoreClient.getFirestore();

        ApiFuture<QuerySnapshot> future = db
                .collection("users")
                .document(userId)
                .collection("emergencyContacts")
                .get();

        return future.get()
                .getDocuments()
                .stream()
                .map(DocumentSnapshot::getData)
                .toList();
    }
}