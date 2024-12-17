
using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IBuildingArticlesService
{
    Task<IEnumerable<BuildingArticlesDto>> GetAllItemsAsync();
    Task<BuildingArticlesDto> GetItemByIdAsync(int id);
    Task<BuildingArticlesDto> CreateItemAsync(BuildingArticlesDto conversationDto);
    Task UpdateItemAsync(int id, BuildingArticlesDto conversationDto);
    Task DeleteItemAsync(int id);
    Task<IEnumerable<BuildingArticlesDto>> GetAllItemsByPlaceAsync(int placeId);
}