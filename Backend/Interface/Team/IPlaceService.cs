using Backend.Dto;

namespace Backend.Interface.Team;

public interface IPlaceService
{
    Task<IEnumerable<PlaceDto>> GetAllPlacesAsync();
    Task<PlaceDto> GetPlaceByIdAsync(int id);
    Task<PlaceDto> CreatePlaceAsync(PlaceDto conversationDto);
    Task UpdatePlaceAsync(int id, PlaceDto conversationDto);
    Task DeletePlaceAsync(int id);
}