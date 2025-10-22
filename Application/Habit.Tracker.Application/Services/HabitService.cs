using AutoMapper;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.Habit;
using Habit.Tracker.Contracts.Dtos.Habit.Create;
using Habit.Tracker.Contracts.Dtos.Habit.DetailDto;
using Habit.Tracker.Contracts.Dtos.Habit.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Repositories;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Habit.Tracker.Domain.Enums;
using Microsoft.AspNetCore.Http;

namespace Habit.Tracker.Application.Services;

public class HabitService : IHabitService
{
    private readonly IValidationService _validationService;
    private readonly ErrorMessageService _errorMessageService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly IHabitRepository _habitRepository;

    public HabitService(IValidationService validationService, 
        ErrorMessageService errorMessageService,
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IHabitRepository habitRepository)
    {
        _validationService = validationService;
        _errorMessageService = errorMessageService;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _habitRepository = habitRepository;
    }
    public async Task<ResponseDto<NoContentDto>> CreateHabit(CreateHabitRequestDto request)
    {
        var validationError = await _validationService.ValidateAsync<CreateHabitRequestDto, NoContentDto>(request);
        if (validationError != null)
            return validationError;

        //HABIT GROUP CHECK
        var habitGroup = await _unitOfWork
            .GetGenericRepository<HabitGroup>().GetByIdAsync(request.HabitGroupId);
        if (habitGroup == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitGroupNotFound, StatusCodes.Status404NotFound);

        //NAME CHECK
        var isHabitExist = await _unitOfWork
            .GetGenericRepository<HabitEntity>()
            .AnyAsync(x => x.Name == request.Name && x.HabitGroupId == request.HabitGroupId);
        if (isHabitExist)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitWithSameNameExists, StatusCodes.Status409Conflict);

        if (!Enum.IsDefined(typeof(PeriodTypeEnum), request.PeriodType))
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.InvalidPeriodType, StatusCodes.Status400BadRequest);


        HabitEntity habit = _mapper.Map<HabitEntity>(request);
        habit.StartDate = DateTime.UtcNow;
        habit.CompletedDaysCount = 0;
        habit.IsActive = false;
        habit.CreatedDate = DateTime.UtcNow;

        await _unitOfWork.GetGenericRepository<HabitEntity>().CreateAsync(habit);

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status201Created);
    }

    public async Task<ResponseDto<NoContentDto>> DeleteHabit(Guid id)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(id);
        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        await _unitOfWork.GetGenericRepository<HabitEntity>().DeleteAsync(habit);
        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<IList<HabitResponseDto>>> GetAllHabits()
    {
        var habits = await _unitOfWork.GetGenericRepository<HabitEntity>().GetAllAsync();

        if(habits == null)
            return ResponseDto<IList<HabitResponseDto>>.Fail(_errorMessageService.HabitNotFound,StatusCodes.Status404NotFound);

        var _habits = _mapper.Map<IList<HabitResponseDto>>(habits);

        return ResponseDto<IList<HabitResponseDto>>.Success(_habits);
    }

    public async Task<ResponseDto<IList<HabitDetailDto>>> GetUserHabitsAsync(Guid userId)
    {
        var habits = await _habitRepository.GetUserHabitsAsync(userId);

        var habitDtos = _mapper.Map<List<HabitDetailDto>>(habits);

        return ResponseDto<IList<HabitDetailDto>>.Success(habitDtos,StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> UpdateHabitAsync(UpdateHabitRequestDto request)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(request.Id);
        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        if (habit.PeriodType != request.PeriodType || habit.Frequency != request.Frequency)
        {
            habit.DailySchedules.Clear();
            habit.WeeklySchedules.Clear();
            habit.MonthlySchedules.Clear();

            habit.PeriodType = request.PeriodType;
            habit.Frequency = request.Frequency;

            habit.IsActive = false; 
        }

        habit.Name = request.Name;
        habit.Notes = request.Notes;
        habit.UpdatedDate = DateTime.UtcNow;

        await _unitOfWork.GetGenericRepository<HabitEntity>().UpdateAsync(habit);

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> ActivateHabitAsync(Guid id)
    {
        var habit = await _unitOfWork.GetGenericRepository<HabitEntity>().GetByIdAsync(id);
        if (habit == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status404NotFound);

        habit.IsActive = true;
        await _unitOfWork.GetGenericRepository<HabitEntity>().UpdateAsync(habit);
        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }
}
