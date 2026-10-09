package safepulse_backend.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import safepulse_backend.model.SosRequest;
import safepulse_backend.service.AuthService;
import safepulse_backend.service.FirestoreService;
import safepulse_backend.service.TwilioService;

@RestController
public class SosController {

    private final AuthService authService;
    private final FirestoreService firestoreService;
    private final TwilioService twilioService;

    public SosController(
            AuthService authService,
            FirestoreService firestoreService,
            TwilioService twilioService) {
        this.authService = authService;
        this.firestoreService = firestoreService;
        this.twilioService = twilioService;
    }

    @PostMapping("/api/sos")
    public Object activateSos(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestBody SosRequest request) throws Exception {

        if (authorizationHeader == null
                || !authorizationHeader.startsWith("Bearer ")) {
            throw new RuntimeException(
                    "Missing or invalid Authorization header");
        }

        String token = authorizationHeader.substring(7);

        String userId = authService.verifyToken(token);

        var contacts = firestoreService.getEmergencyContacts(userId);

        String mapsUrl =
                "https://www.google.com/maps/search/?api=1&query="
                + request.getLatitude()
                + ","
                + request.getLongitude();

        String message =
                "SafePulse SOS ALERT! "
                + "Emergency alert activated. "
                + "Location: " + mapsUrl;

        int sent = 0;

        for (var contact : contacts) {

            Object phoneValue = contact.get("phone");

            if (phoneValue != null) {

                String phone = phoneValue.toString().trim();

                if (!phone.startsWith("+") && phone.length() == 10) {
                    phone = "+91" + phone;
                }

                twilioService.sendSms(phone, message);

                sent++;
            }
        }

        return "SOS sent to " + sent + " emergency contact(s).";
    }
}