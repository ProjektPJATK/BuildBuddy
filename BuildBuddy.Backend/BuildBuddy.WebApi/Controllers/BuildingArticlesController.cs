
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using Microsoft.AspNetCore.Mvc;

namespace BuildBuddy.WebApi.Controllers;

    [Route("api/[controller]")]
    [ApiController]
    public class BuildingArticlesController : ControllerBase
    {
        private readonly IBuildingArticlesService _buildingArticlesService;

        public BuildingArticlesController(IBuildingArticlesService buildingArticlesService)
        {
            _buildingArticlesService = buildingArticlesService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<BuildingArticlesDto>>> GetAllItems()
        {
            var items = await _buildingArticlesService.GetAllItemsAsync();
            return Ok(items);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BuildingArticlesDto>> GetItemById(int id)
        {
            var item = await _buildingArticlesService.GetItemByIdAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return Ok(item);
        }

        [HttpPost]
        public async Task<ActionResult<BuildingArticlesDto>> CreateItem(BuildingArticlesDto buildingArticlesDto)
        {
            var createdItem = await _buildingArticlesService.CreateItemAsync(buildingArticlesDto);
            return CreatedAtAction(nameof(GetItemById), new { id = createdItem.Id }, createdItem);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateItem(int id, BuildingArticlesDto buildingArticlesDto)
        {
            await _buildingArticlesService.UpdateItemAsync(id, buildingArticlesDto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteItem(int id)
        {
            await _buildingArticlesService.DeleteItemAsync(id);
            return NoContent();
        }
        [HttpGet("address/{addressId}")]
        public async Task<IActionResult> GetItemsByPlace(int addressId)
        {
            var items = await _buildingArticlesService.GetAllItemsByPlaceAsync(addressId);
        
            if (items == null || !items.Any())
            {
                return NotFound("No items found for the specified place.");
            }

            return Ok(items);
        }
    }