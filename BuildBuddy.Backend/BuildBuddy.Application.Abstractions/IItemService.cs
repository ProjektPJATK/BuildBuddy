
using BuildBuddy.Contract;

namespace BuildBuddy.Application.Abstractions;

public interface IItemService
{
    Task<IEnumerable<ItemDto>> GetAllItemsAsync();
    Task<ItemDto> GetItemByIdAsync(int id);
    Task<ItemDto> CreateItemAsync(ItemDto conversationDto);
    Task UpdateItemAsync(int id, ItemDto conversationDto);
    Task DeleteItemAsync(int id);
    Task<IEnumerable<ItemDto>> GetAllItemsByPlaceAsync(int placeId);
}