using AutoMapper;
using Habit.Tracker.Contracts.Dtos.DailyHabit.Create;
using Habit.Tracker.Contracts.Dtos.DailySchedule;
using Habit.Tracker.Contracts.Dtos.Habit;
using Habit.Tracker.Contracts.Dtos.Habit.Create;
using Habit.Tracker.Contracts.Dtos.Habit.DetailDto;
using Habit.Tracker.Contracts.Dtos.Habit.Update;
using Habit.Tracker.Contracts.Dtos.HabitGroup;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Create;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler;
using Habit.Tracker.Contracts.Dtos.SpecialReminder;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Create;
using Habit.Tracker.Contracts.Dtos.User;
using Habit.Tracker.Contracts.Dtos.User.Register;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler;
using Habit.Tracker.Domain.Entities;

namespace Habit.Tracker.Application
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<RegisterRequestDto, User>();
            CreateMap<User, UserResponseDto>();
            CreateMap<HabitGroupCreateRequestDto, HabitGroup>();
            CreateMap<HabitGroup, HabitGroupResponseDto>();
            CreateMap<CreateHabitRequestDto, HabitEntity>();
            CreateMap<HabitEntity, HabitDetailDto>()
                .ForMember(dest => dest.DailySchedules, opt => opt.MapFrom(src => src.DailySchedules != null ? src.DailySchedules.ToList() : new List<HabitDaily>()))
                .ForMember(dest => dest.WeeklySchedules, opt => opt.MapFrom(src => src.WeeklySchedules != null ? src.WeeklySchedules.ToList() : new List<HabitWeekly>()))
                .ForMember(dest => dest.MonthlySchedules, opt => opt.MapFrom(src => src.MonthlySchedules != null ? src.MonthlySchedules.ToList() : new List<HabitMonthly>()));
            CreateMap<HabitDaily, HabitDailyDto>();
            CreateMap<HabitWeekly, HabitWeeklyDto>();
            CreateMap<HabitMonthly, HabitMonthlyDto>();
            CreateMap<HabitEntity, HabitResponseDto>();
            CreateMap<HabitEntity, UpdateHabitResponseDto>();
            CreateMap<HabitDaily, DailyHabitResponseDto>();
            CreateMap<HabitWeekly, WeeklySchedulerResponseDto>();
            CreateMap<CreateDailyScheduleDto, HabitDaily>();
            CreateMap<HabitMonthly, MonthlySchedulerResponseDto>();
            CreateMap<CreateSpecialReminderRequestDto,SpecialReminder>(); 
            CreateMap<SpecialReminder, SpecialReminderResponseDto>();

        }
    }
}
