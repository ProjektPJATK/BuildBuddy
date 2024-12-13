using BuildBuddy.Application;
using BuildBuddy.WebSocets;

var builder = WebApplication.CreateBuilder(args);


var configuration = builder.Configuration;

builder.Services.AddBuildBuddyApp(configuration);

builder.Services.AddSignalR();

builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy.AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials()
            .SetIsOriginAllowed(_ => true);
    });
});


var app = builder.Build();

app.UseRouting();
app.UseCors("CorsPolicy");

app.MapHub<ChatHub>("/Chat");

app.Run();
