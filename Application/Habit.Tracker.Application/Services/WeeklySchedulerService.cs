<<<<<<< Updated upstream
﻿namespace Habit.Tracker.Application.Services;
=======
﻿using AutoMapper;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Create;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Habit.Tracker.Domain.Enums;
using Microsoft.AspNetCore.Http;
using Microsoft.IdentityModel.Tokens;
>>>>>>> Stashed changes

public class WeeklySchedulerService
{
<<<<<<< Updated upstream
=======
    private readonly IUnitOfWork _unitOfWork;
    private readonly ErrorMessageService _errorMessageService;
    private readonly IMapper _mapper;
    private readonly IValidationService _validationService;

    public WeeklySchedulerService(
        IUnitOfWork unitOfWork,
        ErrorMessageService errorMessageService,
        IMapper mapper,
        IValidationService validationService)
    {
        _unitOfWork = unitOfWork;
        _errorMessageService = errorMessageService;
        _mapper = mapper;
        _validationService = validationService;
    }
    public async Task<ResponseDto<NoContentDto>> ClearWeeklySchedulersAsync(Guid habitId)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(habitId, h => h.WeeklySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        if (habit.WeeklySchedules.IsNullOrEmpty())
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        await _unitOfWork.GetGenericRepository<HabitWeekly>().RemoveRangeAsync(habit.WeeklySchedules);
        habit.WeeklySchedules.Clear();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> CreateWeeklySchedulerAsync(CreateWeeklySchedulerDto request)
    {
        var validationError = await _validationService.ValidateAsync<CreateWeeklySchedulerDto, NoContentDto>(request);
        if (validationError != null)
            return validationError;

        //HABIT CHECK
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(request.HabitId, x => x.WeeklySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound,StatusCodes.Status404NotFound);

        //HABIT SCHEDULER LIST CHECK
        if (habit.WeeklySchedules.Count() > 0)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HasAlreadySchedulers, StatusCodes.Status400BadRequest);
        
        //HABIT PREİOD TYPE CHECK
        if(habit.PeriodType != PeriodTypeEnum.Weekly)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.WrongPeriodType,StatusCodes.Status400BadRequest);

        //HABIT LIST VALIADTION
        if (request.Schedules.Count != habit.Frequency)
            return ResponseDto<NoContentDto>.Fail(
                $"Bu alışkanlık için {habit.Frequency} farklı gün seçmelisiniz.",
                StatusCodes.Status400BadRequest
            );

        //DAY CONFLICT CHECK
        bool isConflict = request.Schedules
            .GroupBy(s => s.DayOfWeek)
            .Any(g => g.Count() > 1);

        if (isConflict)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.ScheduleDaysConflict, StatusCodes.Status409Conflict);


        habit.WeeklySchedules.Clear();

        //SCHEDULERS CREATION (MANUAL MAPPING)
        foreach (var schedule in request.Schedules)
        {
            var weeklySchedule = new HabitWeekly
            {
                HabitId = habit.Id,
                DayOfWeek = schedule.DayOfWeek,
                ReminderTime = schedule.ReminderTime,
                CreatedDate = DateTime.UtcNow
            };

            habit.WeeklySchedules.Add(weeklySchedule);
        }
        //HABIT ACTIVATION
        habit.IsActive = true;

        _ = await _unitOfWork.SaveChangesAsync();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status201Created);
    }

    public async Task<ResponseDto<IList<WeeklySchedulerResponseDto>>> GetWeeklySchedulersAsync(Guid habitId)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>()
            .GetByIdAsync(habitId);
        if (habit == null)
            return ResponseDto<IList<WeeklySchedulerResponseDto>>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        var weeklyHabits = await _unitOfWork.GetGenericRepository<HabitWeekly>()
            .GetAllAsync(x => x.HabitId == habitId);

        if (weeklyHabits.IsNullOrEmpty())
            return ResponseDto<IList<WeeklySchedulerResponseDto>>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        var _weeklyHabits = _mapper.Map<IList<WeeklySchedulerResponseDto>>(weeklyHabits);

        return ResponseDto<IList<WeeklySchedulerResponseDto>>.Success(_weeklyHabits, StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> UpdateWeeklySchedulerAsync(UpdateWeeklySchedulerDto request)
    {
        var weeklyScheduler = await _unitOfWork.GetGenericRepository<HabitWeekly>().GetByIdAsync(request.Id);

        if (weeklyScheduler == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        if(weeklyScheduler.ReminderTime == request.ReminderTime && weeklyScheduler.DayOfWeek == request.DayOfWeek)
            return ResponseDto<NoContentDto>.Fail($"Bu haftanın {request.DayOfWeek}'ü için {request.ReminderTime} saatinde bir hatırlatıcı zaten var. Lütfen farklı bir zaman seçiniz.", StatusCodes.Status409Conflict);

        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(weeklyScheduler.HabitId, h => h.WeeklySchedules);

        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        if (habit.WeeklySchedules.IsNullOrEmpty())
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.SchedulerNotFound, StatusCodes.Status404NotFound);

        bool hasDuplicate = habit.WeeklySchedules
            .Any(x => x.Id != weeklyScheduler.Id && x.DayOfWeek == request.DayOfWeek);
        if (hasDuplicate)
            return ResponseDto<NoContentDto>.Fail($"Bu haftanın {request.DayOfWeek} günü için bir hatırlatıcı zaten var. Lütfen farklı bir gün seçiniz.", StatusCodes.Status409Conflict);

        weeklyScheduler.DayOfWeek = request.DayOfWeek;
        weeklyScheduler.UpdatedDate = DateTime.UtcNow;
        weeklyScheduler.ReminderTime = request.ReminderTime;

        _ = await _unitOfWork.SaveChangesAsync();

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }
>>>>>>> Stashed changes
}
