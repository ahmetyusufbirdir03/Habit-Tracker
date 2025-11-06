using DotNetEnv;
using FluentValidation.AspNetCore;
using Habit.Tracker.Api.Middleware.ExceptionMiddleware;
using Habit.Tracker.Application;
using Habit.Tracker.Contracts;
using Habit.Tracker.Infrastructure;
using Microsoft.OpenApi.Models;



var builder = WebApplication.CreateBuilder(args);

Console.WriteLine("========== APPLICATION STARTING ==========");
Console.WriteLine($"Current Directory: {Directory.GetCurrentDirectory()}");

var currentDir = Directory.GetCurrentDirectory();

var apiDir = Directory.GetParent(currentDir)?.FullName;

var solutionRoot = Directory.GetParent(apiDir ?? "")?.FullName;

var envPath = Path.Combine(solutionRoot ?? "", ".env");

Console.WriteLine($"Solution Root: {solutionRoot}");
Console.WriteLine($".env Path: {envPath}");
Console.WriteLine($".env Exists: {File.Exists(envPath)}");

if (File.Exists(envPath))
{
    Env.Load(envPath);
    Console.WriteLine(".env loaded successfully!");
}
else
{
    Console.WriteLine(".env NOT FOUND!");
}

builder.Configuration.AddEnvironmentVariables();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddApplication(builder.Configuration);
builder.Services.AddContracts(builder.Configuration);
builder.Services.AddTransient<ExceptionMiddleware>();

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "HABIT TRACKER",
        Version = "v1",
        Description = "Habit Tracker Swagger Client"
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme()
    {
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme()
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});




var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.ConfigureExceptionHandlingMiddleware();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
