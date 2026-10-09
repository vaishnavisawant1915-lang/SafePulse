package safepulse_backend.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    public String verifyToken(String token) throws Exception {

        FirebaseToken decodedToken =
                FirebaseAuth.getInstance().verifyIdToken(token);

        return decodedToken.getUid();
    }
}