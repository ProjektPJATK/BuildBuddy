using BuildBuddy.Application.Abstractions;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class ConversationController : ControllerBase
    {
        private readonly IConversationService _conversationService;

        public ConversationController(IConversationService conversationService)
        {
            _conversationService = conversationService;
        }
        
        [HttpGet("all")]
        public async Task<IActionResult> GetAllConversations()
        {
            var conversations = await _conversationService.GetAllConversationsAsync();
            return Ok(conversations);
        }

        [HttpGet("{conversationId}")]
        public async Task<IActionResult> GetConversationById(int conversationId)
        {
            var conversation = await _conversationService.GetConversationByIdAsync(conversationId);
            if (conversation == null)
            {
                return NotFound();
            }
            return Ok(conversation);
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