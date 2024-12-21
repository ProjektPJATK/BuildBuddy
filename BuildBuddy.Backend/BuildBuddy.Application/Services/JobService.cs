using BuildBuddy.Application.Abstractions;
using BuildBuddy.Contract;
using BuildBuddy.Data.Abstractions;
using BuildBuddy.Data.Model;


namespace BuildBuddy.Application.Services
{
    public class JobService : IJobService
    {
        private readonly IRepositoryCatalog _dbContext;

        public JobService(IRepositoryCatalog dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<JobDto>> GetAllJobsAsync()
        {
            return await _dbContext.Jobs
                .GetAsync(t => new JobDto
                {
                    Id = t.Id,
                    Name = t.Name,
                    Message = t.Message,
                    StartTime = t.StartTime,
                    EndTime = t.EndTime,
                    AllDay = t.AllDay,
                    AddressId = t.PlaceId ?? 0
                });
        }

        public async Task<JobDto> GetJobIdAsync(int id)
        {
            var task = await _dbContext.Jobs
                .GetByID(id);

            if (task == null)
            {
                return null;
            }

            return new JobDto
            {
                Id = task.Id,
                Name = task.Name,
                Message = task.Message,
                StartTime = task.StartTime,
                EndTime = task.EndTime,
                AllDay = task.AllDay,
                AddressId = task.PlaceId ?? 0
            };
        }

        public async Task<JobDto> CreateJobAsync(JobDto jobDto, string jobActualizationMessage = "Job created")
        {
            var job = new Job()
            {
                Name = jobDto.Name,
                Message = jobDto.Message,
                StartTime = jobDto.StartTime,
                EndTime = jobDto.EndTime,
                AllDay = jobDto.AllDay,
                PlaceId = jobDto.AddressId
            };

            _dbContext.Jobs.Insert(job);
            await _dbContext.SaveChangesAsync();

            var jobActualization = new JobActualization
            {
                JobId = job.Id,
                IsDone = false,
                Message = jobActualizationMessage,
                JobImageUrl = new List<string>()
            };

            _dbContext.JobActualizations.Insert(jobActualization);
            await _dbContext.SaveChangesAsync();

            jobDto.Id = job.Id;
            return jobDto;
        }

        public async Task UpdateJobAsync(int id, JobDto jobDto)
        {
            var task = await _dbContext.Jobs.GetByID(id);

            if (task != null)
            {
                task.Name = jobDto.Name;
                task.Message = jobDto.Message;
                task.StartTime = jobDto.StartTime;
                task.EndTime = jobDto.EndTime;
                task.AllDay = jobDto.AllDay;
                task.PlaceId = jobDto.AddressId;
                
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task DeleteJobAsync(int id)
        {
            var task = await _dbContext.Jobs.GetByID(id);
            if (task != null)
            {
                _dbContext.Jobs.Delete(task);
                await _dbContext.SaveChangesAsync();
            }
        }
        
        public async Task<IEnumerable<JobDto>> GetJobByUserIdAsync(int userId)
        {
            var tasks = await _dbContext.UserJobs.GetAsync(
                    mapper: t => new JobDto
                    {
                        Id = t.Job.Id,
                        Name = t.Job.Name,
                        Message = t.Job.Message,
                        StartTime = t.Job.StartTime,
                        EndTime = t.Job.EndTime,
                        AllDay = t.Job.AllDay,
                        AddressId = t.Job.PlaceId ?? 0
                    },
                    filter:ut => ut.UserId == userId,
                    includeProperties: "Tasks");

            return tasks;
        }
        public async Task AssignJobToUserAsync(int taskId, int userId)
        {
            var task = await _dbContext.Jobs.GetByID(taskId);
            if (task == null)
                throw new Exception("Task not found");

            var user = await _dbContext.Users.GetByID(userId);
            if (user == null)
                throw new Exception("User not found");

            var existingAssignments = await _dbContext.UserJobs.GetAsync(
                filter: ut => ut.JobId == taskId && ut.UserId == userId
            );

            if (existingAssignments.Any())
                throw new Exception("Task is already assigned to this user");

            var userTask = new UserJob
            {
                JobId = taskId,
                UserId = userId
            };

            _dbContext.UserJobs.Insert(userTask);
            await _dbContext.SaveChangesAsync();
        }


    }
}
