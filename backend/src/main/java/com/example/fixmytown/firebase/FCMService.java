//package com.example.fixmytown.firebase;
//
//import com.google.firebase.messaging.FirebaseMessaging;
//import com.google.firebase.messaging.Message;
//import com.google.firebase.messaging.Notification;
//import com.google.firebase.messaging.FirebaseMessagingException;
//import org.springframework.stereotype.Service;
//
//@Service
//public class FCMService {
//
//    public void sendNotification(String token, String title, String body) throws FirebaseMessagingException {
//        Message message = Message.builder()
//                .setToken(token)
//                .setNotification(Notification.builder()
//                        .setTitle(title)
//                        .setBody(body)
//                        .build())
//                .build();
//
//        FirebaseMessaging.getInstance().send(message);
//    }
//}
package com.example.fixmytown.firebase;

import com.example.fixmytown.notification.NotificationTokenRepository;
import com.example.fixmytown.appuser.AppUser;
import com.google.firebase.messaging.*;
import org.springframework.stereotype.Service;

@Service
public class FCMService {

    private final NotificationTokenRepository tokenRepo;

    public FCMService(NotificationTokenRepository tokenRepo) {
        this.tokenRepo = tokenRepo;
    }

    public void sendNotificationToUser(AppUser user, String title, String body) throws FirebaseMessagingException {
        String token = tokenRepo.findByUser(user)
                .map(t -> t.getToken())
                .orElseThrow(() -> new IllegalStateException("User has no FCM token"));

        Message message = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build())
                .build();

        FirebaseMessaging.getInstance().send(message);
    }
}
