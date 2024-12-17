using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;

namespace BuildBuddy.Application.Services
{
    public class BuildingArticlesService : IBuildingArticlesService
    {
        private readonly IRepositoryCatalog _dbContext;

        public BuildingArticlesService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<BuildingArticlesDto>> GetAllItemsAsync()
        {
            return await _dbContext.BuildingArticles
                .GetAsync(item => new BuildingArticlesDto
                {
                    Id = item.Id,
                    Name = item.Name,
                    QuantityMax = item.QuantityMax,
                    Metrics = item.Metrics,
                    QuantityLeft = item.QuantityLeft,
                    AddressId = item.AddressId
                });
        }

        public async Task<BuildingArticlesDto> GetItemByIdAsync(int id)
        {
            var item = await _dbContext.BuildingArticles
                .GetByID(id);

            if (item == null)
            {
                return null;
            }

            return new BuildingArticlesDto
            {
                Id = item.Id,
                Name = item.Name,
                QuantityMax = item.QuantityMax,
                Metrics = item.Metrics,
                QuantityLeft = item.QuantityLeft,
                AddressId = item.AddressId
            };
        }

        public async Task<BuildingArticlesDto> CreateItemAsync(BuildingArticlesDto buildingArticlesDto)
        {
            var item = new BuildingArticles
            {
                Name = buildingArticlesDto.Name,
                QuantityMax = buildingArticlesDto.QuantityMax,
                Metrics = buildingArticlesDto.Metrics,
                QuantityLeft = buildingArticlesDto.QuantityLeft,
                AddressId = buildingArticlesDto.AddressId
            };

            _dbContext.BuildingArticles.Insert(item);
            await _dbContext.SaveChangesAsync();

            buildingArticlesDto.Id = item.Id;
            return buildingArticlesDto;
        }

        public async Task UpdateItemAsync(int id, BuildingArticlesDto buildingArticlesDto)
        {
            var item = await _dbContext.BuildingArticles.GetByID(id);

            if (item != null)
            {
                item.Name = buildingArticlesDto.Name;
                item.QuantityMax = buildingArticlesDto.QuantityMax;
                item.Metrics = buildingArticlesDto.Metrics;
                item.QuantityLeft = buildingArticlesDto.QuantityLeft;
                item.AddressId = buildingArticlesDto.AddressId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteItemAsync(int id)
        {
            var item = await _dbContext.BuildingArticles.GetByID(id);
            if (item != null)
            {
                _dbContext.BuildingArticles.Delete(item);
                await _dbContext.SaveChangesAsync();
            }
        }
        public async Task<IEnumerable<BuildingArticlesDto>> GetAllItemsByPlaceAsync(int placeId)
        {
            return await _dbContext.BuildingArticles.GetAsync(item => new BuildingArticlesDto
            {
                Id = item.Id,
                Name = item.Name,
                QuantityMax = item.QuantityMax,
                Metrics = item.Metrics,
                QuantityLeft = item.QuantityLeft,
                AddressId = item.AddressId
            });
        }
    }
}
