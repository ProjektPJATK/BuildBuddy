﻿using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.Team;
using Backend.Model;
using Microsoft.EntityFrameworkCore;

namespace Backend.Service.Team
{
    public class ItemService : IItemService
    {
        private readonly AppDbContext _dbContext;

        public ItemService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<ItemDto>> GetAllItemsAsync()
        {
            return await _dbContext.Items
                .Select(item => new ItemDto
                {
                    Id = item.Id,
                    Name = item.Name,
                    QuantityMax = item.QuantityMax,
                    Metrics = item.Metrics,
                    QuantityLeft = item.QuantityLeft,
                    PlaceId = item.PlaceId
                })
                .ToListAsync();
        }

        public async Task<ItemDto> GetItemByIdAsync(int id)
        {
            var item = await _dbContext.Items
                .FirstOrDefaultAsync(i => i.Id == id);

            if (item == null)
            {
                return null;
            }

            return new ItemDto
            {
                Id = item.Id,
                Name = item.Name,
                QuantityMax = item.QuantityMax,
                Metrics = item.Metrics,
                QuantityLeft = item.QuantityLeft,
                PlaceId = item.PlaceId
            };
        }

        public async Task<ItemDto> CreateItemAsync(ItemDto itemDto)
        {
            var item = new Item
            {
                Name = itemDto.Name,
                QuantityMax = itemDto.QuantityMax,
                Metrics = itemDto.Metrics,
                QuantityLeft = itemDto.QuantityLeft,
                PlaceId = itemDto.PlaceId
            };

            _dbContext.Items.Add(item);
            await _dbContext.SaveChangesAsync();

            itemDto.Id = item.Id;
            return itemDto;
        }

        public async Task UpdateItemAsync(int id, ItemDto itemDto)
        {
            var item = await _dbContext.Items.FirstOrDefaultAsync(i => i.Id == id);

            if (item != null)
            {
                item.Name = itemDto.Name;
                item.QuantityMax = itemDto.QuantityMax;
                item.Metrics = itemDto.Metrics;
                item.QuantityLeft = itemDto.QuantityLeft;
                item.PlaceId = itemDto.PlaceId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteItemAsync(int id)
        {
            var item = await _dbContext.Items.FirstOrDefaultAsync(i => i.Id == id);
            if (item != null)
            {
                _dbContext.Items.Remove(item);
                await _dbContext.SaveChangesAsync();
            }
        }
        public async Task<IEnumerable<ItemDto>> GetAllItemsByPlaceAsync(int placeId)
        {
            return await _dbContext.Items
                .Where(item => item.PlaceId == placeId)
                .Select(item => new ItemDto
                {
                    Id = item.Id,
                    Name = item.Name,
                    QuantityMax = item.QuantityMax,
                    Metrics = item.Metrics,
                    QuantityLeft = item.QuantityLeft,
                    PlaceId = item.PlaceId
                })
                .ToListAsync();
        }
    }
}
