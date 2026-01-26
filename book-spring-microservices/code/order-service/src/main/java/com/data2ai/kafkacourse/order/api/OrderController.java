package com.data2ai.kafkacourse.order.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

  @GetMapping("/ping")
  public Mono<String> ping() {
    return Mono.just("order-service:ok");
  }
}
