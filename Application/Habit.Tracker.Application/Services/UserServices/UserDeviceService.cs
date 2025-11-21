using Habit.Tracker.Application.Services.UtilServices;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Create;
using Habit.Tracker.Contracts.Dtos.User.Device;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Http;

namespace Habit.Tracker.Application.Services.UserServices;

public class UserDeviceService : IUserDeviceService
{
    private readonly ErrorMessageService _errorMessageService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IValidationService _validationService;

    public UserDeviceService(
        ErrorMessageService errorMessageService, 
        IUnitOfWork unitOfWork, 
        IValidationService 
        validationService)
    {
        _errorMessageService = errorMessageService;
        _unitOfWork = unitOfWork;
        _validationService = validationService;
    }

    public async Task<ResponseDto<NoContentDto>> SaveDeviceTokenAsync(SaveDeviceTokenRequestDto request)
    {
        var validationError = await _validationService.ValidateAsync<SaveDeviceTokenRequestDto, NoContentDto>(request);
        if (validationError != null)
            return validationError;

        var user = await _unitOfWork.GetGenericRepository<User>().GetByIdAsync(request.UserId);
        if (user == null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

        var devices = await _unitOfWork.GetGenericRepository<UserDevice>().GetAllAsync(q => q.FcmToken == request.Token);
        var device = devices.FirstOrDefault();

        if (devices.Count == 0)
        {
            var newDevice = new UserDevice
            {
                Id = Guid.NewGuid(),
                UserId = request.UserId,
                FcmToken = request.Token,
                Platform = request.Platform, 
                LastActiveDate = DateTime.UtcNow,
                CreatedDate = DateTime.UtcNow
            };

            await _unitOfWork.GetGenericRepository<UserDevice>().CreateAsync(newDevice);
        }
        else { 
            device!.LastActiveDate = DateTime.UtcNow;
            device!.UserId = request.UserId;
            device!.Platform = request.Platform;
        }
        await _unitOfWork.SaveChangesAsync();
        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }
}
