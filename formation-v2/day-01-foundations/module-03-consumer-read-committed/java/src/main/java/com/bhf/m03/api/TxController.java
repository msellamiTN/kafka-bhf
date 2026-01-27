package com.bhf.m03.api;

import com.bhf.m03.kafka.TransactionalProducerService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/tx")
public class TxController {

    private final TransactionalProducerService producerService;

    public TxController(TransactionalProducerService producerService) {
        this.producerService = producerService;
    }

    @PostMapping("/commit")
    public ResponseEntity<Map<String, Object>> commit(@RequestParam("txId") String txId) throws Exception {
        producerService.produceCommitted(txId);

        Map<String, Object> resp = new HashMap<>();
        resp.put("txId", txId);
        resp.put("status", "COMMITTED");
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/abort")
    public ResponseEntity<Map<String, Object>> abort(@RequestParam("txId") String txId) throws Exception {
        producerService.produceAborted(txId);

        Map<String, Object> resp = new HashMap<>();
        resp.put("txId", txId);
        resp.put("status", "ABORTED");
        return ResponseEntity.ok(resp);
    }
}
