using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services
{
    public class PlaceService : IPlaceService
    {
        private readonly IRepositoryCatalog _dbContext;

        public PlaceService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<PlaceDto>> GetAllPlacesAsync()
        {
            return await _dbContext.Places
                .GetAsync(place => new PlaceDto
                {
                    Id = place.Id,
                    Address = place.Address,
                });
        }

        public async Task<PlaceDto> GetPlaceByIdAsync(int id)
        {
            var place = await _dbContext.Places
                .GetByID(id);

            if (place == null)
            {
                return null;
            }

            return new PlaceDto
            {
                Id = place.Id,
                Address = place.Address,
            };
        }

        public async Task<PlaceDto> CreatePlaceAsync(PlaceDto placeDto)
        {
            var place = new Place
            {
                Address = placeDto.Address,
            };

            _dbContext.Places.Insert(place);
            await _dbContext.SaveChangesAsync();

            placeDto.Id = place.Id;
            return placeDto;
        }

        public async Task UpdatePlaceAsync(int id, PlaceDto placeDto)
        {
            var place = await _dbContext.Places.GetByID(id);

            if (place != null)
            {
                place.Address = placeDto.Address;
                
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeletePlaceAsync(int id)
        {
            var place = await _dbContext.Places.GetByID(id);
            if (place != null)
            {
                _dbContext.Places.Delete(place);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
