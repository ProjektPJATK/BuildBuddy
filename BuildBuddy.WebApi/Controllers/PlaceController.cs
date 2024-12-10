
using Microsoft.AspNetCore.Mvc;
using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;

namespace Backend.Controller.Team
{
    [Route("api/[controller]")]
    [ApiController]
    public class PlaceController : ControllerBase
    {
        private readonly IPlaceService _placeService;

        public PlaceController(IPlaceService placeService)
        {
            _placeService = placeService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<PlaceDto>>> GetAllPlaces()
        {
            var places = await _placeService.GetAllPlacesAsync();
            return Ok(places);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PlaceDto>> GetPlaceById(int id)
        {
            var place = await _placeService.GetPlaceByIdAsync(id);
            if (place == null)
            {
                return NotFound();
            }
            return Ok(place);
        }

        [HttpPost]
        public async Task<ActionResult<PlaceDto>> CreatePlace(PlaceDto placeDto)
        {
            var createdPlace = await _placeService.CreatePlaceAsync(placeDto);
            return CreatedAtAction(nameof(GetPlaceById), new { id = createdPlace.Id }, createdPlace);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePlace(int id, PlaceDto placeDto)
        {
            await _placeService.UpdatePlaceAsync(id, placeDto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePlace(int id)
        {
            await _placeService.DeletePlaceAsync(id);
            return NoContent();
        }
    }
}