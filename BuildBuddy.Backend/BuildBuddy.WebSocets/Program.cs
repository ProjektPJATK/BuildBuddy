using BuildBuddy.Application;
using BuildBuddy.WebSocets;
using Microsoft.AspNetCore.SignalR;

var builder = WebApplication.CreateBuilder(args);


var configuration = builder.Configuration;

builder.Services.AddBuildBuddyApp(configuration);

builder.Services.AddSignalR();
builder.Services.AddSingleton<IUserIdProvider, QueryStringUserIdProvider>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy
            .WithOrigins("https://green-flower-058ace803.4.azurestaticapps.net")
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();  
    });
});

var app = builder.Build();

app.UseRouting();

app.UseCors("CorsPolicy");

app.MapHub<ChatHub>("/Chat").RequireCors("CorsPolicy");

app.Run();
