using Backend.Dto;
using Backend.Interface.Team;

namespace Backend.Service.Team;

public class PlaceService : IPlaceService
{
    public Task<IEnumerable<PlaceDto>> GetAllPlacesAsync()
    {
        throw new NotImplementedException();
    }

    public Task<PlaceDto> GetPlaceByIdAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task<PlaceDto> CreatePlaceAsync(PlaceDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task UpdatePlaceAsync(int id, PlaceDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task DeletePlaceAsync(int id)
    {
        throw new NotImplementedException();
    }
}