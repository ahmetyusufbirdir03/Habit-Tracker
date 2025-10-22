using DotNetEnv;
using FluentValidation.AspNetCore;
using Habit.Tracker.Api.Middleware.ExceptionMiddleware;
using Habit.Tracker.Application;
using Habit.Tracker.Contracts;
using Habit.Tracker.Infrastructure;



var builder = WebApplication.CreateBuilder(args);

Env.Load();

builder.Configuration.AddEnvironmentVariables();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddApplication(builder.Configuration);
builder.Services.AddContracts(builder.Configuration);
builder.Services.AddTransient<ExceptionMiddleware>();


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
