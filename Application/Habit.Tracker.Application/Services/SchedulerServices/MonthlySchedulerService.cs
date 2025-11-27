using AutoMapper;
using Habit.Tracker.Application.Services.UtilServices;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Create;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Habit.Tracker.Domain.Enums;
using Microsoft.AspNetCore.Http;
using Microsoft.IdentityModel.Tokens;

namespace Habit.Tracker.Application.Services.SchedulerServices;

public class MonthlySchedulerService : IMonthlySchedulerService
{
    private readonly ErrorMessageService _errorMessageService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly IValidationService _validationService;

    public MonthlySchedulerService(
        ErrorMessageService errorMessageService,
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IValidationService validationService)
    {
        _errorMessageService = errorMessageService;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _validationService = validationService;
    }

    public async Task<ResponseDto<NoContentDto>> ClearMonthlySchedulerAsync(Guid habitId)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(habitId, h => h.MonthlySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        if (habit.MonthlySchedules.IsNullOrEmpty())
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        await _unitOfWork.GetGenericRepository<HabitMonthly>().RemoveRangeAsync(habit.MonthlySchedules);

        habit.MonthlySchedules.Clear();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> CompleteMonthlySchedulerAsync(Guid schedulerId)
    {
        var scheduler = await _unitOfWork.GetGenericRepository<HabitMonthly>().GetByIdAsync(schedulerId);
        if (scheduler == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(scheduler.HabitId, h => h.MonthlySchedules);
        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        scheduler.IsDone = true;

        if (habit.MonthlySchedules.All(item => item.IsDone))
        {
            habit.IsDone = true;
            habit.Streak += 1;
            if (habit.Streak > habit.BestStreak)
            {
                habit.BestStreak = habit.Streak;
            }
        }

        await _unitOfWork.SaveChangesAsync();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }


    public async Task<ResponseDto<NoContentDto>> CreateMonthlySchedulerAsync(CreateMonthlySchedulerDto request)
    {
        //REQUEST VALIDATION
        var validationError = await _validationService.ValidateAsync<CreateMonthlySchedulerDto, NoContentDto>(request);

        if (validationError != null)
            return validationError; 

        //HABIT CHECK
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(request.HabitId, x => x.MonthlySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        //HABIT SCHEDULER LIST CHECK
        if (habit.MonthlySchedules.Count() > 0)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HasAlreadySchedulers, StatusCodes.Status400BadRequest);

        //HABIT PREİOD TYPE CHECK
        if (habit.PeriodType != PeriodTypeEnum.Monthly)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.WrongPeriodType, StatusCodes.Status400BadRequest);

        if (request.Schedules.Count != habit.Frequency)
            return ResponseDto<NoContentDto>.Fail(
                $"Bu alışkanlık için {habit.Frequency} farklı gün seçmelisiniz.",
                StatusCodes.Status400BadRequest
            );

        //DAY CONFLICT CHECK
        bool isConflict = request.Schedules
            .GroupBy(s => s.DayOfMonth)
            .Any(g => g.Count() > 1);

        if (isConflict)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.ScheduleDaysConflict, StatusCodes.Status409Conflict);
            
        habit.MonthlySchedules.Clear();

        //SCHEDULERS CREATION (MANUAL MAPPING)
        foreach (var schedule in request.Schedules)
        {
            int daysInMonth = DateTime.DaysInMonth(DateTime.UtcNow.Year, DateTime.UtcNow.Month);
            int day = Math.Min(schedule.DayOfMonth, daysInMonth);

            var monthlySchedule = new HabitMonthly
            {
                HabitId = habit.Id,
                DayOfMonth = day,
                ReminderTime = schedule.ReminderTime,
                CreatedDate = DateTime.UtcNow
            };

            habit.MonthlySchedules.Add(monthlySchedule);
        }
        //HABIT ACTIVATION
        habit.IsActive = true;

        _ = await _unitOfWork.SaveChangesAsync();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status201Created);
    }

    public async Task<ResponseDto<IList<MonthlySchedulerResponseDto>>> GetMonthlySchedulersAsync(Guid habitId)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>()
            .GetByIdAsync(habitId);

        if (habit == null)
            return ResponseDto<IList<MonthlySchedulerResponseDto>>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        var monthlySchedulers = await _unitOfWork.GetGenericRepository<HabitMonthly>()
            .GetAllAsync(x => x.HabitId == habitId);

        if (monthlySchedulers.IsNullOrEmpty())
            return ResponseDto<IList<MonthlySchedulerResponseDto>>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        var _monthlySchedulers = _mapper.Map<IList<MonthlySchedulerResponseDto>>(monthlySchedulers);

        return ResponseDto<IList<MonthlySchedulerResponseDto>>.Success(_monthlySchedulers, StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> UpdateMonthlySchedulerAsync(UpdateMonthlySchedulerDto request)
    {
        //SCHEDULER CHECK
        var monthlyScheduler = await _unitOfWork.GetGenericRepository<HabitMonthly>().GetByIdAsync(request.Id);

        if (monthlyScheduler == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        //SAME DAY-TIME REUPDATE CONFLICT CHECK 
        if (monthlyScheduler.DayOfMonth == request.DayOfMonth && monthlyScheduler.ReminderTime == request.ReminderTime)
        {
            return ResponseDto<NoContentDto>.Fail(
                $"There is already a reminder set for day {request.DayOfMonth} of this month at {request.ReminderTime}. Please choose a different day or time.",
                StatusCodes.Status409Conflict 
            );
        }
        //HABIT CHEK
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(monthlyScheduler.HabitId, h => h.MonthlySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);
        
        //SCHEDULERS LIST CHECK
        if (habit.MonthlySchedules.IsNullOrEmpty())
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        //SAME DAY CONFLICT CHECK
        bool hasDuplicate = habit.MonthlySchedules
           .Any(x => x.Id != monthlyScheduler.Id && x.DayOfMonth == request.DayOfMonth);
        if (hasDuplicate)
            return ResponseDto<NoContentDto>.Fail($"A reminder already exists for day {request.DayOfMonth} of this month. Please choose a different day.", StatusCodes.Status409Conflict);

        //MANUAL MAPPING
        monthlyScheduler.DayOfMonth = request.DayOfMonth;
        monthlyScheduler.UpdatedDate = DateTime.UtcNow;
        monthlyScheduler.ReminderTime = request.ReminderTime;

        _ = await _unitOfWork.SaveChangesAsync();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }
}
