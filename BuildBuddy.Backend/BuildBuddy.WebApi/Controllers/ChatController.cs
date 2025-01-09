using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class ChatController : ControllerBase
{
    private readonly ChatService _chatService;

    public ChatController(ChatService chatService)
    {
        _chatService = chatService;
    }

    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadMessagesCount([FromBody]int userId)
    {
        int count = await _chatService.GetUnreadMessagesCount(userId);
        return Ok(new { UnreadCount = count });
    }

    [HttpPost("mark-as-read")]
    public async Task<IActionResult> MarkMessageAsRead([FromBody] int conversationId, [FromBody] int userId)
    {
        await _chatService.MarkMessagesAsRead(conversationId, userId);
        return Ok();
    }
    [HttpPost("exit-chat")]
    public async Task<IActionResult> ExitChat([FromBody] int conversationId, [FromBody] int userId)
    {
        await _chatService.ResetReadStatus(conversationId, userId);
        return Ok();
    }
}