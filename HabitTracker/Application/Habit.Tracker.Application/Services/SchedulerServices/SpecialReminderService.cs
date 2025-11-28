using AutoMapper;
using Habit.Tracker.Application.Services.UtilServices;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.SpecialReminder;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Create;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Http;

namespace Habit.Tracker.Application.Services.SchedulerServices;

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

    public async Task<ResponseDto<NoContentDto>> UpdateSpecialReminderAsync(UpdateSpecialReminderRequestDto request)
    {
        var validationError = await _validationService
            .ValidateAsync<UpdateSpecialReminderRequestDto, NoContentDto>(request);

        if (validationError != null)
            return validationError;

        var specialReminder = await _unitOfWork
            .GetGenericRepository<SpecialReminder>()
            .GetByIdAsync(request.Id);

        if (specialReminder == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.ReminderNotFound, 404);


        bool allFieldsEmpty =
            string.IsNullOrWhiteSpace(request.Title) &&
            string.IsNullOrWhiteSpace(request.Description) &&
            request.Day == specialReminder.Day &&
            request.Month == specialReminder.Month;

        if (string.IsNullOrWhiteSpace(request.Title)
            && string.IsNullOrWhiteSpace(request.Description)
            && request.Day == specialReminder.Day
            && request.Month == specialReminder.Month)
        {
            return ResponseDto<NoContentDto>.Fail("There is no change to update", 400);
        }

        bool changed =
            !string.IsNullOrWhiteSpace(request.Title) &&
             request.Title.Trim() != specialReminder.Title ||
            !string.IsNullOrWhiteSpace(request.Description) &&
             request.Description.Trim() != specialReminder.Description ||
            request.Day != specialReminder.Day ||
            request.Month != specialReminder.Month;

        if (!changed)
        {
            return ResponseDto<NoContentDto>.Fail("There is no change to update", 400);
        }

        var hGroup = await _unitOfWork
            .GetGenericRepository<HabitGroup>()
            .GetByIdAsync(specialReminder.HabitGroupId, h => h.SpecialReminders);

        if (hGroup == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.ReminderNotFound, 404);

        var duplicate = hGroup.SpecialReminders
            .FirstOrDefault(r =>
                r.Id != specialReminder.Id &&
                r.Month == request.Month &&
                r.Day == request.Day &&
                !string.IsNullOrWhiteSpace(r.Title) &&
                !string.IsNullOrWhiteSpace(request.Title) &&
                r.Title.Equals(request.Title, StringComparison.OrdinalIgnoreCase));

        if (duplicate != null)
        {
            return ResponseDto<NoContentDto>.Fail(
                _errorMessageService.ReminderAlreadyExistsWithSameNameAndDate,
                409
            );
        }

        if (!string.IsNullOrWhiteSpace(request.Title))
            specialReminder.Title = request.Title.Trim();

        if (!string.IsNullOrWhiteSpace(request.Description))
            specialReminder.Description = request.Description.Trim();

        if (request.Day != specialReminder.Day)
            specialReminder.Day = request.Day;

        if (request.Month != specialReminder.Month)
            specialReminder.Month = request.Month;

        await _unitOfWork.SaveChangesAsync();
        return ResponseDto<NoContentDto>.Success(200);
    }

}
