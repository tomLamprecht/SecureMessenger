package de.thws.biedermann.messenger.demo.alive.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AliveController {

    @GetMapping(value = "/alive")
    public ResponseEntity<String> getAlive(){
        return ResponseEntity
                .ok()
                .body("Alive");
    }
}
