package com.bhf.m03.api;

import com.bhf.m03.kafka.ReadCommittedConsumerService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class MetricsController {

    private final ReadCommittedConsumerService consumerService;

    public MetricsController(ReadCommittedConsumerService consumerService) {
        this.consumerService = consumerService;
    }

    @GetMapping("/metrics")
    public ResponseEntity<Map<String, Object>> metrics() {
        return ResponseEntity.ok(consumerService.metrics());
    }
}
