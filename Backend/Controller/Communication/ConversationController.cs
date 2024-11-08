using Backend.Interface.Communication;
using Backend.Service.Communication;
using Backend.SignaRHub;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controller.Communication;

    [Route("api/[controller]")]
    [ApiController]
    public class ConversationController : ControllerBase
    {
        private readonly IConversationService _conversationService;

        public ConversationController(IConversationService conversationService)
        {
            _conversationService = conversationService;
        }

        [HttpPost("create")]
        public async Task<IActionResult> CreateConversation(int user1Id, int user2Id)
        {
            var conversationId = await _conversationService.CreateConversationAsync(user1Id, user2Id);
            return Ok(new { ConversationId = conversationId });
        }

        [HttpPost("{conversationId}/addUser")]
        public async Task<IActionResult> AddUserToConversation(int conversationId, int userId)
        {
            await _conversationService.AddUserToConversationAsync(conversationId, userId);
            return Ok();
        }
    }