using AutoMapper;
using Habit.Tracker.Application.Services.UtilServices;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.User;
using Habit.Tracker.Contracts.Dtos.User.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;

namespace Habit.Tracker.Application.Services.UserServices;

public class UserService : IUserService
{
    private readonly IValidationService _validationService;
    private readonly UserManager<User> _userManager;
    private readonly ErrorMessageService _errorMessageService;
    private readonly IMapper _mapper;
    private readonly IUnitOfWork _unitOfWork;

    public UserService(IValidationService validationService,
        UserManager<User> userManager,
        ErrorMessageService errorMessageService,
        IMapper mapper,
        IUnitOfWork unitOfWork) 
    {
        _validationService = validationService;
        _userManager = userManager;
        _errorMessageService = errorMessageService;
        _mapper = mapper;
        _unitOfWork = unitOfWork;
    }

    public async Task<ResponseDto<NoContentDto>> DeleteUserAsync(Guid id)
    {
        var user = await _unitOfWork.GetGenericRepository<User>().GetByIdAsync(id);
        if (user == null)
            return ResponseDto<NoContentDto>
                .Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

        await _unitOfWork.GetGenericRepository<User>().DeleteAsync(user);

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }
    public async Task<ResponseDto<IList<UserResponseDto>>> GetAllUsers()
    {
       
        var users = await _unitOfWork.GetGenericRepository<User>().GetAllAsync();
        if (!users.Any())
            return ResponseDto<IList<UserResponseDto>>.Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

        IList<UserResponseDto> _users = _mapper.Map<IList<UserResponseDto>>(users);

        return ResponseDto<IList<UserResponseDto>>.Success(_users, StatusCodes.Status200OK);
    }
    public async Task<ResponseDto<UserResponseDto>> GetUserByEmailAsync(string email)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if(user == null) 
            return ResponseDto<UserResponseDto>.Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

        var userResponse = _mapper.Map<UserResponseDto>(user);

        return ResponseDto<UserResponseDto>.Success(userResponse, StatusCodes.Status200OK);
    }
    public async Task<ResponseDto<UserResponseDto>> UpdateUserAsync(UpdateUserDto request)
    {
        // 1) Validator kontrolü
        var validationError = await _validationService.ValidateAsync<UpdateUserDto, UserResponseDto>(request);
        if (validationError != null)
            return validationError;

        // 2) User bul
        var user = await _userManager.FindByIdAsync(request.Id.ToString());
        if (user == null)
            return ResponseDto<UserResponseDto>.Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

            // 3) Tüm değerler boş mu kontrol et
        bool hasAnyValue =
            !string.IsNullOrWhiteSpace(request.Username) ||
            !string.IsNullOrWhiteSpace(request.Email) ||
            !string.IsNullOrWhiteSpace(request.PhoneNumber);

        if (!hasAnyValue)
            return ResponseDto<UserResponseDto>.Fail(
                "Güncellenecek bir değer bulunamadı.",
                StatusCodes.Status400BadRequest
            );

        // 4) Username kontrol
        if (!string.IsNullOrWhiteSpace(request.Username))
        {
            if (request.Username == user.UserName)
                return ResponseDto<UserResponseDto>.Fail(
                    "Yeni kullanıcı adı mevcut kullanıcı adıyla aynı olamaz.",
                    StatusCodes.Status400BadRequest
                );
            user.UserName = request.Username;
        }

        // 5) Email kontrol
        bool isEmailExist = await _unitOfWork.GetGenericRepository<User>().AnyAsync(x => x.Email == request.Email && x.Id != request.Id);
        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            if (request.Email == user.Email)
                return ResponseDto<UserResponseDto>.Fail(
                    "Yeni email mevcut email ile aynı olamaz.",
                    StatusCodes.Status400BadRequest
                );
            if (isEmailExist)
            {
                return ResponseDto<UserResponseDto>.Fail(
                    "Bu mail adresi zaten kayıtlı.",
                    StatusCodes.Status400BadRequest
                );
            }
            user.Email = request.Email;
        }

        // 6) PhoneNumber kontrol
        bool isPhoneNuberExist = await _unitOfWork.GetGenericRepository<User>().AnyAsync(x => x.PhoneNumber == request.PhoneNumber && x.Id != request.Id);
        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            if (request.PhoneNumber == user.PhoneNumber)
                return ResponseDto<UserResponseDto>.Fail(
                    "Yeni telefon numarası mevcut numarayla aynı olamaz.",
                    StatusCodes.Status400BadRequest
                );
            if (isPhoneNuberExist)
            {
                return ResponseDto<UserResponseDto>.Fail(
                    "Bu telefon numarası zaten kayıtlı.",
                    StatusCodes.Status400BadRequest
                );
            }
            user.PhoneNumber = request.PhoneNumber;
        }

        // 7) DB update
        var updateResult = await _userManager.UpdateAsync(user);
        if (!updateResult.Succeeded)
            return ResponseDto<UserResponseDto>.Fail(updateResult.Errors.Select(e => e.Description).ToList(), StatusCodes.Status500InternalServerError);

            // 8) Response
            var responseDto = new UserResponseDto
            {
                Id = user.Id,
                Username = user.UserName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,

            };

            return ResponseDto<UserResponseDto>.Success(responseDto, StatusCodes.Status200OK);
        }

}
