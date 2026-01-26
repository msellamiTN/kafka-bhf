package com.data2ai.kafkacourse.inventory.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {

  @GetMapping("/ping")
  public Mono<String> ping() {
    return Mono.just("inventory-service:ok");
  }
}
