package com.bhf.m02.api;

import com.bhf.m02.kafka.ProducerService;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class ProducerController {

    private final ProducerService producerService;

    public ProducerController(ProducerService producerService) {
        this.producerService = producerService;
    }

    @PostMapping("/send")
    public ResponseEntity<Map<String, Object>> send(
            @RequestParam("mode") String mode,
            @RequestParam("eventId") String eventId,
            @RequestParam(value = "topic", defaultValue = "bhf-transactions") String topic,
            @RequestParam(value = "sendMode", defaultValue = "sync") String sendMode,
            @RequestParam(value = "key", required = false) String key,
            @RequestParam(value = "partition", required = false) Integer partition
    ) throws Exception {
        boolean idempotent = "idempotent".equalsIgnoreCase(mode);

        boolean async = "async".equalsIgnoreCase(sendMode) || "asynchronous".equalsIgnoreCase(sendMode);
        String keyEffective = (key == null || key.isBlank()) ? eventId : key;

        String value = "{\"eventId\":\"" + eventId + "\",\"mode\":\"" + mode + "\",\"sendMode\":\"" + sendMode + "\",\"api\":\"java\",\"ts\":\"" + Instant.now() + "\"}";

        if (async) {
            String requestId = producerService.sendAsync(idempotent, topic, partition, keyEffective, value);

            Map<String, Object> resp = new HashMap<>();
            resp.put("requestId", requestId);
            resp.put("state", "PENDING");
            resp.put("eventId", eventId);
            resp.put("mode", mode);
            resp.put("sendMode", sendMode);
            resp.put("topic", topic);
            resp.put("key", keyEffective);
            resp.put("partition", partition);

            return ResponseEntity.accepted().body(resp);
        }

        RecordMetadata metadata = producerService.sendSync(idempotent, topic, partition, keyEffective, value);

        Map<String, Object> resp = new HashMap<>();
        resp.put("eventId", eventId);
        resp.put("mode", mode);
        resp.put("sendMode", sendMode);
        resp.put("topic", topic);
        resp.put("key", keyEffective);
        resp.put("partition", metadata.partition());
        resp.put("offset", metadata.offset());

        return ResponseEntity.ok(resp);
    }

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> status(@RequestParam("requestId") String requestId) {
        Map<String, Object> status = producerService.getStatus(requestId);
        if (status == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(status);
    }
}
