using System.Text;
using Amazon.Runtime;
using Amazon.S3;
using Amazon.Translate;
using Backend.DbContext;
using Backend.Interface.Calendar;
using Backend.Interface.Communication;
using Backend.Interface.Tasks;
using Backend.Interface.Team;
using Backend.Interface.User;
using Backend.Model;
using Backend.Service.Calendar;
using Backend.Service.Communication;
using Backend.Service.Tasks;
using Backend.Service.Team;
using Backend.Service.User;
using Backend.SignaRHub;
using Backend.StorageService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
var configuration = builder.Configuration;

builder.Services.AddSignalR();

var awsAccessKey = builder.Configuration["AWS:AccessKey"];
var awsSecretKey = builder.Configuration["AWS:SecretKey"];
var awsRegion = builder.Configuration["AWS:Region"];

builder.Services.Configure<AwsOptions>(builder.Configuration.GetSection("AWS"));

builder.Services.AddSingleton<IAmazonTranslate>(new AmazonTranslateClient(
    new BasicAWSCredentials(awsAccessKey, awsSecretKey),
    Amazon.RegionEndpoint.GetBySystemName(awsRegion)
));
builder.Services.AddSingleton<IAmazonS3>(new AmazonS3Client(
    new BasicAWSCredentials(awsAccessKey, awsSecretKey),
    Amazon.RegionEndpoint.GetBySystemName(awsRegion)
));

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Your API", Version = "v1" });
    
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement{
    {
        new OpenApiSecurityScheme{
            Reference = new OpenApiReference{
                Id = "Bearer",
                Type = ReferenceType.SecurityScheme
            }
        }, new List<string>()
    }});
});builder.Services.AddControllers();


builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = configuration["Jwt:Issuer"],
        ValidAudience = configuration["Jwt:Issuer"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]))
    };
});
 

builder.Services.AddScoped<IItemService, ItemService>();
builder.Services.AddScoped<ICalendarService, CalendarService>();
builder.Services.AddScoped<ITaskActualizationService, TaskActualizationService>();
builder.Services.AddScoped<ITaskService, TaskService>();
builder.Services.AddScoped<IPlaceService, PlaceService>();
builder.Services.AddScoped<ITeamService, TeamService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IConversationService, ConversationService>();
builder.Services.AddScoped<IStorageService, StorageService>();




var app = builder.Build();
app.UseCors("AllowAll");

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.MapControllers();
app.UseRouting();


app.MapHub<ChatHub>("/chat-hub");

app.Run();
