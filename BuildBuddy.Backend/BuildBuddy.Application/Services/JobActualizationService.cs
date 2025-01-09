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
        

        public async Task<JobActualizationDto> GetJobActualizationByIdAsync(int jobActualizationId)
        {
            var jobActualization = await _dbContext.JobActualizations
                .GetByID(jobActualizationId);

            if (jobActualization == null)
            {
                return null;
            }

            var ta = jobActualization;
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

        public async Task UpdateJobActualizationAsync(int jobActualizationId, JobActualizationDto jobActualizationDto)
        {
            var jobActualization = await _dbContext.JobActualizations
                .GetByID(jobActualizationId);

            
            if (jobActualization != null)
            {
                var ta = jobActualization;
                ta.Message = jobActualizationDto.Message;
                ta.IsDone = jobActualizationDto.IsDone;
                ta.JobImageUrl = jobActualizationDto.JobImageUrl;
                ta.JobId = jobActualizationDto.JobId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteJobActualizationAsync(int jobActualizationId)
        {
            var jobActualization = await _dbContext.JobActualizations
                .GetByID(jobActualizationId);

            if (jobActualization != null)
            {
                var ta = jobActualization;
                _dbContext.JobActualizations.Delete(ta);
                await _dbContext.SaveChangesAsync();
            }
        }
        
        public async Task AddJobImageAsync(int jobActualizationId, Stream imageStream, string imageName)
        {
            const string prefix = "job";
            var job = await _dbContext.JobActualizations
                .GetByID(jobActualizationId);
            if (job == null) throw new Exception("Task not found");
            

            var imageUrl = await _fileStorage.UploadImageAsync(imageStream, imageName, prefix);
            job.JobImageUrl.Add(imageUrl);

            _dbContext.JobActualizations.Update(job);
            await _dbContext.SaveChangesAsync();
        }
        
        public async Task<IEnumerable<string>> GetJobImagesAsync(int jobActualizationId)
        {
            var job = await _dbContext.JobActualizations
                .GetByID(jobActualizationId);
            if (job == null) throw new Exception("Task not found");

            return job.JobImageUrl;
        }

        public async Task RemoveJobImageAsync(int jobActualizationId, string imageUrl)
        {
            var job = await _dbContext.JobActualizations
                .GetByID(jobActualizationId);
            if (job == null) throw new Exception("Task not found");
            
            await _fileStorage.DeleteFileAsync(imageUrl);
            job.JobImageUrl.Remove(imageUrl);

            _dbContext.JobActualizations.Update(job);
            await _dbContext.SaveChangesAsync();
        }
    }
}
