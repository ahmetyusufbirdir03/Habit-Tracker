using AutoMapper;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.Habit;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler;
using Habit.Tracker.Contracts.Dtos.SpecialReminder;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Create;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Http;
using System.Text.RegularExpressions;

namespace Habit.Tracker.Application.Services;

public class SpecialReminderService : ISpecialReminderService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ErrorMessageService _errorMessageService;
    private readonly IValidationService _validationService;

    public SpecialReminderService(
        IUnitOfWork unitOfWork,
        IMapper mapper,
        ErrorMessageService errorMessageService,
        IValidationService validationService)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _errorMessageService = errorMessageService;
        _validationService = validationService;
    }
    public async Task<ResponseDto<NoContentDto>> CreateSpecialReminderAsync(CreateSpecialReminderRequestDto request)
    {
        var validationError = await _validationService.ValidateAsync<CreateSpecialReminderRequestDto, NoContentDto>(request);
        if (validationError != null)
            return validationError;

        var hGroup = await _unitOfWork
            .GetGenericRepository<HabitGroup>()
            .GetByIdAsync(
                request.HabitGroupId,
                h => h.SpecialReminders 
            );
        if (hGroup == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.MaxReminderCount, StatusCodes.Status404NotFound);

        if (hGroup.SpecialReminders != null && hGroup.SpecialReminders.Count >= 10)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitNotFound, StatusCodes.Status400BadRequest);

        var existingReminder = hGroup.SpecialReminders
            .FirstOrDefault(r =>
                r.Month == request.Month &&
                r.Day == request.Day &&
                r.Title != null &&
                r.Title.Equals(request.Title, StringComparison.OrdinalIgnoreCase)
            );

        if (existingReminder != null)
        {
            return ResponseDto<NoContentDto>.Fail(
                _errorMessageService.ReminderAlreadyExistsWithSameNameAndDate,
                StatusCodes.Status409Conflict
            );
        }

        SpecialReminder reminder = _mapper.Map<SpecialReminder>(request);
        await _unitOfWork.GetGenericRepository<SpecialReminder>().CreateAsync(reminder);

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> DeleteSpecialReminderAsync(Guid reminderId)
    {
        var reminder = await _unitOfWork
            .GetGenericRepository<SpecialReminder>().GetByIdAsync(reminderId);
        if (reminder == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.ReminderNotFound, StatusCodes.Status404NotFound);

        await _unitOfWork.GetGenericRepository<SpecialReminder>().DeleteAsync(reminder);
        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<IList<SpecialReminderResponseDto>>> GetSpecialReminderAsync(Guid habitGroupId)
    {
        var group = await _unitOfWork.GetGenericRepository<HabitGroup>().GetByIdAsync(habitGroupId);
        if (group == null)
            return ResponseDto<IList<SpecialReminderResponseDto>>.Fail(_errorMessageService.HabitGroupNotFound, StatusCodes.Status404NotFound);

        var reminders = await _unitOfWork.GetGenericRepository<SpecialReminder>().GetAllAsync(x => x.HabitGroupId == habitGroupId);
        if (reminders.Count == 0)
            return ResponseDto<IList<SpecialReminderResponseDto>>.Fail(_errorMessageService.ReminderNotFound, StatusCodes.Status404NotFound);

        var habitDtos = _mapper.Map<List<SpecialReminderResponseDto>>(reminders);

        return ResponseDto<IList<SpecialReminderResponseDto>>.Success(habitDtos, StatusCodes.Status200OK);
    }

    public Task<ResponseDto<NoContentDto>> UpdateSpecialReminderAsync()
    {
        throw new NotImplementedException();
    }
}
