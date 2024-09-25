using Backend.DbContext;
using Backend.Dto;
using Backend.Interface.Team;
using Backend.Model;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Service.Team
{
    public class PlaceService : IPlaceService
    {
        private readonly AppDbContext _dbContext;

        public PlaceService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<PlaceDto>> GetAllPlacesAsync()
        {
            return await _dbContext.Places
                .Select(place => new PlaceDto
                {
                    Id = place.Id,
                    Address = place.Address,
                    InventoryId = place.InventoryId,
                })
                .ToListAsync();
        }

        public async Task<PlaceDto> GetPlaceByIdAsync(int id)
        {
            var place = await _dbContext.Places
                .FirstOrDefaultAsync(p => p.Id == id);

            if (place == null)
            {
                return null;
            }

            return new PlaceDto
            {
                Id = place.Id,
                Address = place.Address,
                InventoryId = place.InventoryId,
            };
        }

        public async Task<PlaceDto> CreatePlaceAsync(PlaceDto placeDto)
        {
            var place = new Place
            {
                Address = placeDto.Address,
                InventoryId = placeDto.InventoryId,
            };

            _dbContext.Places.Add(place);
            await _dbContext.SaveChangesAsync();

            placeDto.Id = place.Id;
            return placeDto;
        }

        public async Task UpdatePlaceAsync(int id, PlaceDto placeDto)
        {
            var place = await _dbContext.Places.FirstOrDefaultAsync(p => p.Id == id);

            if (place != null)
            {
                place.Address = placeDto.Address;
                place.InventoryId = placeDto.InventoryId;
                
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeletePlaceAsync(int id)
        {
            var place = await _dbContext.Places.FirstOrDefaultAsync(p => p.Id == id);
            if (place != null)
            {
                _dbContext.Places.Remove(place);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
