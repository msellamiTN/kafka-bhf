package com.data2ai.kafkacourse.payment.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

  @GetMapping("/ping")
  public Mono<String> ping() {
    return Mono.just("payment-service:ok");
  }
}
