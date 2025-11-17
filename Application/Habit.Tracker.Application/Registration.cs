using Habit.Tracker.Application.Services;
using Habit.Tracker.Application.Services.TokenServices;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace Habit.Tracker.Application;

public static class Registration
{
    public static void AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<TokenSettings>(configuration.GetSection("JWT"));
        services.AddLocalization(options => options.ResourcesPath = "Resources");
        services.AddScoped<IValidationService, ValidationService>();
        services.AddScoped(typeof(IUserService), typeof(UserService));
        services.AddScoped(typeof(IAuthService), typeof(AuthService));
        services.AddScoped(typeof(IHabitGroupService), typeof(HabitGroupService));
        services.AddScoped(typeof(IHabitService), typeof(HabitService));
        services.AddScoped(typeof(IDailyScheduleService), typeof(DailyScheduleService));
        services.AddScoped(typeof(IWeeklySchedulerService), typeof(WeeklySchedulerService));
        services.AddScoped(typeof(IMonthlySchedulerService), typeof(MonthlySchedulerService));
        services.AddScoped(typeof(ISpecialReminderService), typeof(SpecialReminderService));

        services.AddScoped<ErrorMessageService>();

        services.AddTransient<ITokenService, TokenService>();
        services.AddAutoMapper(typeof(MappingProfile).Assembly);

        services.AddAuthentication(opt =>
        {
            opt.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            opt.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        }).AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, opt =>
        {
            opt.SaveToken = true;
            opt.TokenValidationParameters = new TokenValidationParameters()
            {
                ValidateIssuer = false,
                ValidateAudience = false,
                ValidateLifetime = false,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey
                (Encoding.UTF8.GetBytes(configuration["JWT:Secret"])),
                ValidIssuer = configuration["JWT:Issuer"],
                ValidAudience = configuration["JWT:Audience"],
                ClockSkew = TimeSpan.Zero
            };
        });

    }
}
