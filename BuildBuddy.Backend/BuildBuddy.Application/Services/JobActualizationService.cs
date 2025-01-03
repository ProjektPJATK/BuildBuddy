using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;
using BuildBuddy.Storage.Abstraction;

namespace BuildBuddy.Application.Services
{
    public class JobActualizationService : IJobActualizationService
    {
        private readonly IRepositoryCatalog _dbContext;
        private readonly IFileStorageRepository _fileStorage;

        public JobActualizationService(IRepositoryCatalog dbContext, IFileStorageRepository fileStorage)
        {
            _dbContext = dbContext;
            _fileStorage = fileStorage;
        }

        public async Task<IEnumerable<JobActualizationDto>> GetAllJobsActualizationAsync()
        {
            return await _dbContext.JobActualizations
                .GetAsync(ta => new JobActualizationDto
                {
                    Id = ta.Id,
                    Message = ta.Message,
                    IsDone = ta.IsDone,
                    JobImageUrl = ta.JobImageUrl,
                    JobId = ta.JobId
                });
        }
        

        public async Task<JobActualizationDto> GetJobActualizationByIdAsync(int jobId)
        {
            var jobActualization = await _dbContext.JobActualizations
                .GetAsync(filter: ta => ta.JobId == jobId);

            if (jobActualization == null || !jobActualization.Any())
            {
                return null;
            }

            var ta = jobActualization.First();
            return new JobActualizationDto
            {
                Id = ta.Id,
                Message = ta.Message,
                IsDone = ta.IsDone,
                JobImageUrl = ta.JobImageUrl,
                JobId = ta.JobId
            };
        }

        public async Task<JobActualizationDto> CreateJobActualizationAsync(JobActualizationDto jobActualizationDto)
        {
            var jobActualization = new JobActualization
            {
                Message = jobActualizationDto.Message,
                IsDone = jobActualizationDto.IsDone,
                JobImageUrl = jobActualizationDto.JobImageUrl,
                JobId = jobActualizationDto.JobId
            };

            _dbContext.JobActualizations.Insert(jobActualization);
            await _dbContext.SaveChangesAsync();

            jobActualizationDto.Id = jobActualization.Id;
            return jobActualizationDto;
        }

        public async Task UpdateJobActualizationAsync(int jobId, JobActualizationDto jobActualizationDto)
        {
            var jobActualization = await _dbContext.JobActualizations
                .GetAsync(filter: ta => ta.JobId == jobId);

            
            if (jobActualization != null)
            {
                var ta = jobActualization.First();
                ta.Message = jobActualizationDto.Message;
                ta.IsDone = jobActualizationDto.IsDone;
                ta.JobImageUrl = jobActualizationDto.JobImageUrl;
                ta.JobId = jobActualizationDto.JobId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteJobActualizationAsync(int jobId)
        {
            var jobActualization = await _dbContext.JobActualizations
                .GetAsync(filter: ta => ta.JobId == jobId);

            if (jobActualization != null)
            {
                var ta = jobActualization.First();
                _dbContext.JobActualizations.Delete(ta);
                await _dbContext.SaveChangesAsync();
            }
        }
        
        public async Task AddJobImageAsync(int jobId, Stream imageStream, string imageName)
        {
            const string prefix = "job";
            var job = await _dbContext.JobActualizations
                .GetAsync(filter: ta => ta.JobId == jobId);
            if (job == null) throw new Exception("Task not found");
            var ja = job.First();

            var imageUrl = await _fileStorage.UploadImageAsync(imageStream, imageName, prefix);
            ja.JobImageUrl.Add(imageUrl);

            _dbContext.JobActualizations.Update(ja);
            await _dbContext.SaveChangesAsync();
        }
        
        public async Task<IEnumerable<string>> GetJobImagesAsync(int jobId)
        {
            var job = await _dbContext.JobActualizations
                .GetAsync(filter: ta => ta.JobId == jobId);
            if (job == null) throw new Exception("Task not found");

            return job.First().JobImageUrl;
        }

        public async Task RemoveJobImageAsync(int jobId, string imageUrl)
        {
            var job = await _dbContext.JobActualizations
                .GetAsync(filter: ta => ta.JobId == jobId);
            if (job == null) throw new Exception("Task not found");
            
            await _fileStorage.DeleteFileAsync(imageUrl);
            var task = job.First();
            task.JobImageUrl.Remove(imageUrl);

            _dbContext.JobActualizations.Update(task);
            await _dbContext.SaveChangesAsync();
        }
    }
}
