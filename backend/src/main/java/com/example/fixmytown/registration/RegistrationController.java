

package com.example.fixmytown.registration;

import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(path = "api/v1/registration")
@AllArgsConstructor
public class RegistrationController {

    private final RegistrationService registrationService;

    @PostMapping
    public ResponseEntity<String> register(@RequestBody RegistrationRequest request) {
        try {
            String result = registrationService.register(request);
            return ResponseEntity.ok(result); // status 200
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(e.getMessage()); // status 400
        }
    }


    @GetMapping(path = "confirm")
    public ResponseEntity<String> confirm(@RequestParam("token") String token) {
        registrationService.confirmToken(token);

        String html = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Account Activated</title>
  <style>
    body {
      background: linear-gradient(to bottom right, #e0f7e9, #f1fdf6);
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      display: flex;
      justify-content: center;
      align-items: flex-start;
      height: 100vh;
      margin: 0;
      padding-top: 160px;
    }
    .card {
      background: #ffffff;
      padding: 50px 40px;
      border-radius: 16px;
      box-shadow: 0 6px 20px rgba(0,0,0,0.1);
      text-align: center;
      max-width: 500px;
    }
    .icon {
      font-size: 100px;
      color: #2e7d32;
      margin-bottom: 25px;
    }
    h2 {
      font-size: 55px;
      margin-bottom: 40px;
      color: #2e7d32;
    }
    p {
      font-size: 40px;
      color: #333;
      margin: 8px 0;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">&#10003;</div> <!-- checkmark fără emoji -->
    <h2>Account Activated Successfully</h2>
    <p>You can now return to the FixMyTown app and log in.</p>
    <p>Thank you for confirming your email.</p>
  </div>
</body>
</html>
""";


        return ResponseEntity.ok().body(html);
    }


}
