using AutoMapper;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.DailyHabit.Create;
using Habit.Tracker.Contracts.Dtos.DailySchedule;
using Habit.Tracker.Contracts.Dtos.DailySchedule.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Habit.Tracker.Domain.Enums;
using Microsoft.AspNetCore.Http;
using Microsoft.IdentityModel.Tokens;

namespace Habit.Tracker.Application.Services;

public class DailyScheduleService : IDailyScheduleService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ErrorMessageService _errorMessageService;
    private readonly IValidationService _validationService;
    private readonly IMapper _mapper;

    public DailyScheduleService(
        IUnitOfWork unitOfWork,
        ErrorMessageService errorMessageService,
        IValidationService validationService,
        IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _errorMessageService = errorMessageService;
        _validationService = validationService;
        _mapper = mapper;
    }

    public async Task<ResponseDto<NoContentDto>> ClearHabitSchedulesAsync(Guid habitId)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(habitId, h => h.DailySchedules);
        if(habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        if(habit.DailySchedules.IsNullOrEmpty())
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        await _unitOfWork.GetGenericRepository<HabitDaily>().RemoveRangeAsync(habit.DailySchedules);
        habit.DailySchedules.Clear();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> CreateDailyScheduleAsync(CreateDailyScheduleRequestDto request)
    {
        var validationError = await _validationService.ValidateAsync<CreateDailyScheduleRequestDto, NoContentDto>(request);
        if (validationError != null)
            return validationError;

        var habit = await _unitOfWork
            .GetGenericRepository<HabitEntity>()
            .GetByIdAsync(request.HabitId, h => h.DailySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        if (habit.PeriodType != PeriodTypeEnum.Daily)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.WrongPeriodType, StatusCodes.Status400BadRequest);

        habit.DailySchedules.Clear();

        foreach (var time in request.ReminderTimes)
        {
           var schedule =new CreateDailyScheduleDto
           {
                HabitId = habit.Id,
                ReminderTime = time
           };

            habit.DailySchedules.Add(_mapper.Map<HabitDaily>(schedule));
        }
        habit.IsActive = true;
        await _unitOfWork.GetGenericRepository<HabitEntity>().UpdateAsync(habit);
        return ResponseDto<NoContentDto>.Success(StatusCodes.Status201Created);
    }

    public async Task<ResponseDto<IList<DailyHabitResponseDto>>> GetHabitSchedulesAsync(Guid habitId)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>()
            .GetByIdAsync(habitId);
        if(habit == null)
            return ResponseDto<IList<DailyHabitResponseDto>>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        var dailyHabits = await _unitOfWork.GetGenericRepository<HabitDaily>()
            .GetAllAsync(x => x.HabitId == habitId);
        
        if (dailyHabits.IsNullOrEmpty())
            return ResponseDto<IList<DailyHabitResponseDto>>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        var _dailyHabits = _mapper.Map<IList<DailyHabitResponseDto>>(dailyHabits);

        return ResponseDto<IList<DailyHabitResponseDto>>.Success(_dailyHabits, StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> UpdateDailyScheduleAsync(UpdateDailySchedulerRequestDto request)
    {
        var daily = await _unitOfWork.GetGenericRepository<HabitDaily>().GetByIdAsync(request.Id);
        if(daily == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(daily.HabitId, h => h.DailySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        if(habit.DailySchedules.IsNullOrEmpty())
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        foreach (var scheduler in habit.DailySchedules)
        {
            if(scheduler.ReminderTime == request.ReminderTime) 
                return ResponseDto<NoContentDto>.Fail(_errorMessageService.ThisTimerAlreadyExist, StatusCodes.Status404NotFound);
        }

        daily.ReminderTime = request.ReminderTime;

        await _unitOfWork.SaveChangesAsync();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

}
