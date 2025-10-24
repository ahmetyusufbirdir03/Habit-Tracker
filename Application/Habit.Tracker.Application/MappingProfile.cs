using AutoMapper;
using Habit.Tracker.Contracts.Dtos.DailyHabit.Create;
using Habit.Tracker.Contracts.Dtos.DailySchedule;
using Habit.Tracker.Contracts.Dtos.Habit;
using Habit.Tracker.Contracts.Dtos.Habit.Create;
using Habit.Tracker.Contracts.Dtos.Habit.DetailDto;
using Habit.Tracker.Contracts.Dtos.HabitGroup;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Create;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler;
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
            CreateMap<HabitEntity, HabitResponseDto>();
            CreateMap<HabitDaily, DailyHabitResponseDto>();
            CreateMap<HabitWeekly, WeeklySchedulerResponseDto>();
            CreateMap<CreateDailyScheduleDto, HabitDaily>();
            CreateMap<HabitMonthly, MonthlySchedulerResponseDto>();

            CreateMap<HabitEntity, HabitDetailDto>()
            .ForMember(dest => dest.HabitGroupId, opt => opt.MapFrom(src => src.HabitGroupId))
            .ForMember(dest => dest.DailySchedules, opt => opt.MapFrom(src => src.DailySchedules))
            .ForMember(dest => dest.WeeklySchedules, opt => opt.MapFrom(src => src.WeeklySchedules))
            .ForMember(dest => dest.MonthlySchedules, opt => opt.MapFrom(src => src.MonthlySchedules));

            // DailySchedules map
            CreateMap<HabitDaily, HabitDailyDto>();

            // WeeklySchedules map
            CreateMap<HabitWeekly, HabitWeeklyDto>()
                .ForMember(dest => dest.DayOfWeek, opt => opt.MapFrom(src => src.DayOfWeek.ToString()));
            // Enum -> string dönüşümü için ToString()

            // MonthlySchedules map
            CreateMap<HabitMonthly, HabitMonthlyDto>();
        }
    }
}
