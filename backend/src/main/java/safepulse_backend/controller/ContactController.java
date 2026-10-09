package safepulse_backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import safepulse_backend.service.AuthService;
import safepulse_backend.service.FirestoreService;

@RestController
public class ContactController {

    private final FirestoreService firestoreService;
    private final AuthService authService;

    public ContactController(
            FirestoreService firestoreService,
            AuthService authService) {
        this.firestoreService = firestoreService;
        this.authService = authService;
    }

    @GetMapping("/api/contacts")
    public Object getEmergencyContacts(
            @RequestHeader("Authorization") String authorizationHeader)
            throws Exception {

        if (authorizationHeader == null
                || !authorizationHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Missing or invalid Authorization header");
        }

        String token = authorizationHeader.substring(7);

        String userId = authService.verifyToken(token);

        return firestoreService.getEmergencyContacts(userId);
    }
}