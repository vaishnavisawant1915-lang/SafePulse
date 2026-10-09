package safepulse_backend.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import org.springframework.stereotype.Service;

@Service
public class TwilioService {

    private final String accountSid = System.getenv("TWILIO_ACCOUNT_SID");
    private final String authToken = System.getenv("TWILIO_AUTH_TOKEN");
    private final String fromNumber = System.getenv("TWILIO_FROM_NUMBER");

    public TwilioService() {
        Twilio.init(accountSid, authToken);
    }

    public void sendSms(String to, String body) {

        Message.creator(
                new PhoneNumber(to),
                new PhoneNumber(fromNumber),
                body
        ).create();
    }
}