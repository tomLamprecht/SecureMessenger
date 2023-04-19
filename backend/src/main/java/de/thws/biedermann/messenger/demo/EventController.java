package de.thws.biedermann.messenger.demo;

import org.springframework.http.codec.ServerSentEvent;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import java.time.Duration;

@RestController
public class EventController {

    @GetMapping("/events")
    public Flux<ServerSentEvent<String>> getEvents() {
        return Flux.interval( Duration.ofSeconds(1))
                .map(sequence -> ServerSentEvent.<String>builder()
                        .id(String.valueOf(sequence))
                        .event("ping")
                        .data("Hello, world!")
                        .build());
    }
}
