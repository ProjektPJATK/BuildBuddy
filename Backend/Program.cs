using Backend.DbContext;
using Backend.Interface.Calendar;
using Backend.Interface.Tasks;
using Backend.Interface.Team;
using Backend.Interface.User;
using Backend.Model;
using Backend.Service.Calendar;
using Backend.Service.Tasks;
using Backend.Service.Team;
using Backend.Service.User;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddControllers();
 

builder.Services.AddScoped<IItemService, ItemService>();
builder.Services.AddScoped<ICalendarService, CalendarService>();
builder.Services.AddScoped<ITaskActualizationService, TaskActualizationService>();
builder.Services.AddScoped<ITaskService, TaskService>();
builder.Services.AddScoped<IPlaceService, PlaceService>();
builder.Services.AddScoped<ITeamService, TeamService>();
builder.Services.AddScoped<IUserService, UserService>();


var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.MapControllers();


app.Run();
