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

        public async Task<JobActualizationDto> GetJobActualizationByIdAsync(int id)
        {
            var taskActualization = await _dbContext.JobActualizations 
                .GetByID(id);

            if (taskActualization == null)
            {
                return null;
            }

            return new JobActualizationDto
            {
                Id = taskActualization.Id,
                Message = taskActualization.Message,
                IsDone = taskActualization.IsDone,
                JobImageUrl = taskActualization.JobImageUrl,
                JobId = taskActualization.JobId
            };
        }

        public async Task<JobActualizationDto> CreateJobActualizationAsync(JobActualizationDto jobActualizationDto)
        {
            var taskActualization = new JobActualization
            {
                Message = jobActualizationDto.Message,
                IsDone = jobActualizationDto.IsDone,
                JobImageUrl = jobActualizationDto.JobImageUrl,
                JobId = jobActualizationDto.JobId
            };

            _dbContext.JobActualizations.Insert(taskActualization);
            await _dbContext.SaveChangesAsync();

            jobActualizationDto.Id = taskActualization.Id;
            return jobActualizationDto;
        }

        public async Task UpdateJobActualizationAsync(int id, JobActualizationDto jobActualizationDto)
        {
            var taskActualization = await _dbContext.JobActualizations
                .GetByID(id);

            if (taskActualization != null)
            {
                taskActualization.Message = jobActualizationDto.Message;
                taskActualization.IsDone = jobActualizationDto.IsDone;
                taskActualization.JobImageUrl = jobActualizationDto.JobImageUrl;
                taskActualization.JobId = jobActualizationDto.JobId;

                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteJobActualizationAsync(int id)
        {
            var taskActualization = await _dbContext.JobActualizations
                .GetByID(id);

            if (taskActualization != null)
            {
                _dbContext.JobActualizations.Delete(taskActualization);
                await _dbContext.SaveChangesAsync();
            }
        }
        
        public async Task AddJobImageAsync(int taskId, Stream imageStream, string imageName)
        {
            const string prefix = "task";
            var task = await _dbContext.JobActualizations.GetByID(taskId);
            if (task == null) throw new Exception("Task not found");

            var imageUrl = await _fileStorage.UploadImageAsync(imageStream, imageName, prefix);
            task.JobImageUrl.Add(imageUrl);

            _dbContext.JobActualizations.Update(task);
            await _dbContext.SaveChangesAsync();
        }
        
        public async Task<IEnumerable<string>> GetJobImagesAsync(int taskId)
        {
            var task = await _dbContext.JobActualizations.GetByID(taskId);
            if (task == null) throw new Exception("Task not found");

            return task.JobImageUrl;
        }

        public async Task RemoveJobImageAsync(int taskId, string imageUrl)
        {
            var task = await _dbContext.JobActualizations.GetByID(taskId);
            if (task == null) throw new Exception("Task not found");
            
            await _fileStorage.DeleteFileAsync(imageUrl);

            task.JobImageUrl.Remove(imageUrl);

            _dbContext.JobActualizations.Update(task);
            await _dbContext.SaveChangesAsync();
        }
    }
}
