using Backend.Dto;
using Backend.Interface.Team;

namespace Backend.Service.Team;

public class ItemService : IItemService
{
    public Task<IEnumerable<ItemDto>> GetAllItemsAsync()
    {
        throw new NotImplementedException();
    }

    public Task<ItemDto> GetItemByIdAsync(int id)
    {
        throw new NotImplementedException();
    }

    public Task<ItemDto> CreateItemAsync(ItemDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task UpdateItemAsync(int id, ItemDto conversationDto)
    {
        throw new NotImplementedException();
    }

    public Task DeleteItemAsync(int id)
    {
        throw new NotImplementedException();
    }
}