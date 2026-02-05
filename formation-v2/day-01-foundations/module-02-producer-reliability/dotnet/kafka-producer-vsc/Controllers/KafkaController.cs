using Microsoft.AspNetCore.Mvc;
using M02ProducerReliability.Api.Services;

namespace M02ProducerReliability.Api.Controllers
{
    [ApiController]
    [Route("api/v1")]
    public class KafkaController : ControllerBase
    {
        private readonly IKafkaProducerService _producerService;
        private readonly ILogger<KafkaController> _logger;

        public KafkaController(IKafkaProducerService producerService, ILogger<KafkaController> logger)
        {
            _producerService = producerService;
            _logger = logger;
        }

        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok("OK");
        }

        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromQuery] string mode, [FromQuery] string eventId, 
            [FromQuery] string? topic = null, [FromQuery] string? sendMode = null, [FromQuery] string? key = null)
        {
            try
            {
                // Validation des paramètres requis
                if (string.IsNullOrWhiteSpace(mode))
                    return BadRequest("Missing query parameter: mode");
                
                if (string.IsNullOrWhiteSpace(eventId))
                    return BadRequest("Missing query parameter: eventId");

                // Valeurs par défaut
                topic ??= "bhf-transactions";
                sendMode ??= "sync";
                key ??= eventId;

                // Conversion des modes
                bool isIdempotent = mode.Equals("idempotent", StringComparison.OrdinalIgnoreCase);
                bool isAsync = sendMode.Equals("async", StringComparison.OrdinalIgnoreCase);

                // Création du message
                var message = $"{{\"eventId\":\"{eventId}\",\"mode\":\"{mode}\",\"sendMode\":\"{sendMode}\",\"api\":\"kafka_producer\",\"ts\":\"{DateTimeOffset.UtcNow:O}\"}}";

                _logger.LogInformation("Sending message: {EventId} in {Mode} mode", eventId, mode);

                // Envoyer le message
                var result = await _producerService.SendMessageAsync(
                    topic, 
                    key, 
                    message,
                    isIdempotent,
                    isAsync);

                return Ok(new 
                {
                    success = true,
                    topic = result.Topic,
                    partition = result.Partition,
                    offset = result.Offset,
                    mode = isIdempotent ? "idempotent" : "plain",
                    sendMode = isAsync ? "async" : "sync"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending message");
                return StatusCode(500, $"Error sending message: {ex.Message}");
            }
        }
    }
}
