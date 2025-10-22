using AutoMapper;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.User;
using Habit.Tracker.Contracts.Dtos.User.Login;
using Habit.Tracker.Contracts.Dtos.User.Register;
using Habit.Tracker.Contracts.Dtos.User.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System.IdentityModel.Tokens.Jwt;

namespace Habit.Tracker.Application.Services;

public class UserService : IUserService
{
    private readonly IValidationService _validationService;
    private readonly UserManager<User> _userManager;
    private readonly ErrorMessageService _errorMessageService;
    private readonly IMapper _mapper;
    private readonly ITokenService _tokenService;
    private readonly IConfiguration _configuration;
    private readonly RoleManager<Role> _roleManager;
    private readonly IUnitOfWork _unitOfWork;

    public UserService(IValidationService validationService,
        UserManager<User> userManager,
        ErrorMessageService errorMessageService,
        IMapper mapper,
        ITokenService tokenService,
        IConfiguration configuration,
        RoleManager<Role> roleManager,
        IUnitOfWork unitOfWork) 
    {
        _validationService = validationService;
        _userManager = userManager;
        _errorMessageService = errorMessageService;
        _mapper = mapper;
        _tokenService = tokenService;
        _configuration = configuration;
        _roleManager = roleManager;
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
    public async Task<ResponseDto<LoginResponseDto>> LoginAsync(LoginRequestDto request)
    {
        var validationError = await _validationService.ValidateAsync<LoginRequestDto, LoginResponseDto>(request);
        if (validationError != null)
            return validationError;


        User? user = await _userManager.FindByEmailAsync(request.Email); 
        if(user == null)
        {
            return ResponseDto<LoginResponseDto>.Fail(_errorMessageService.EmailNotFound, StatusCodes.Status404NotFound);
        }
        bool checkPassword = await _userManager.CheckPasswordAsync(user, request.Password);

        if (user == null || !checkPassword)
            return ResponseDto<LoginResponseDto>.Fail(_errorMessageService.InvalidAuthenticationCredentials, StatusCodes.Status401Unauthorized);

        IList<string> roles = await _userManager.GetRolesAsync(user);

        JwtSecurityToken token = await _tokenService.CreateToken(user, roles);
        string refreshToken = _tokenService.GenerateRefreshToken();

        _ = int.TryParse(_configuration["JWT:RefreshTokenValidityInDays"], out int refreshTokenValidityInDays);

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.Now.AddDays(refreshTokenValidityInDays);

        await _userManager.UpdateAsync(user);
        await _userManager.UpdateSecurityStampAsync(user);

        string _token = new JwtSecurityTokenHandler().WriteToken(token);

        return ResponseDto<LoginResponseDto>
            .Success(
                new LoginResponseDto
                {
                    Token = _token,
                    RefreshToken = refreshToken,
                    Expiration = token.ValidTo
                },
                StatusCodes.Status200OK
            );
    }
    public async Task<ResponseDto<RegisterResponseDto>> RegisterAsync(RegisterRequestDto request)
    {
        var _request = request;

        // Validation Rules Check
        var validationError = await _validationService.ValidateAsync<RegisterRequestDto, RegisterResponseDto>(request);
        if (validationError != null)
            return validationError;

        // Email Conflict Check
        var isEmailExist = await _userManager.FindByEmailAsync(request.Email);
        if (isEmailExist is not null)
            return ResponseDto<RegisterResponseDto>.Fail(_errorMessageService.EmailAlreadyRegistered, StatusCodes.Status409Conflict);

        // Phone Number Conflict Check
        var isPhoneNumberExist = await _userManager.Users.FirstOrDefaultAsync(x => x.PhoneNumber == request.PhoneNumber);
        if (isPhoneNumberExist is not null)
        {
            return ResponseDto<RegisterResponseDto>.Fail(_errorMessageService.PhoneNumberAlreadyRegistered, StatusCodes.Status409Conflict);
        }
        
        // Username Conflict Check
        var isUsernameExist = await _userManager.Users.FirstOrDefaultAsync(x => x.UserName == request.UserName);
        if (isUsernameExist is not null)
        {
            return ResponseDto<RegisterResponseDto>.Fail(_errorMessageService.UsernameAlreadyTaken, StatusCodes.Status409Conflict);
        }

        User user = _mapper.Map<User>(request);

        user.UserName = request.UserName.Trim().ToLowerInvariant();
        user.SecurityStamp = Guid.NewGuid().ToString();

        IdentityResult result = await _userManager.CreateAsync(user, request.Password);
        if (result.Succeeded)
        {
            if (!await _roleManager.RoleExistsAsync("user"))
                await _roleManager.CreateAsync(new Role
                {
                    Name = "user",
                    NormalizedName = "USER",
                    ConcurrencyStamp = Guid.NewGuid().ToString(),
                });

            await _userManager.AddToRoleAsync(user, "user");
        }

        //Create Access Token
        IList<string> roles = await _userManager.GetRolesAsync(user);

        JwtSecurityToken token = await _tokenService.CreateToken(user, roles);
        string refreshToken = _tokenService.GenerateRefreshToken();

        _ = int.TryParse(_configuration["JWT:RefreshTokenValidityInDays"], out int refreshTokenValidityInDays);

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.Now.AddDays(refreshTokenValidityInDays);

        string _token = new JwtSecurityTokenHandler().WriteToken(token);

        await _userManager.UpdateAsync(user);

        return ResponseDto<RegisterResponseDto>.Success(
            new RegisterResponseDto
            {
                    Token = _token,
                    RefreshToken = refreshToken,
                    Expiration = token.ValidTo
            },
            StatusCodes.Status201Created);
    }
    public async Task<ResponseDto<UpdateUserResponseDto>> UpdateUserAsync(UpdateUserDto request)
{
    // 1) Validator kontrolü
    var validationError = await _validationService.ValidateAsync<UpdateUserDto, UpdateUserResponseDto>(request);
    if (validationError != null)
        return validationError;

    // 2) User bul
    var user = await _userManager.FindByIdAsync(request.Id.ToString());
    if (user == null)
        return ResponseDto<UpdateUserResponseDto>.Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

    // 3) Tüm değerler boş mu kontrol et
    bool hasAnyValue =
        !string.IsNullOrWhiteSpace(request.Username) ||
        !string.IsNullOrWhiteSpace(request.Email) ||
        !string.IsNullOrWhiteSpace(request.PhoneNumber) ||
        !string.IsNullOrWhiteSpace(request.NewPassword);

    if (!hasAnyValue)
        return ResponseDto<UpdateUserResponseDto>.Fail(
            "Güncellenecek bir değer bulunamadı.",
            StatusCodes.Status400BadRequest
        );

    // 4) Username kontrol
    if (!string.IsNullOrWhiteSpace(request.Username))
    {
        if (request.Username == user.UserName)
            return ResponseDto<UpdateUserResponseDto>.Fail(
                "Yeni kullanıcı adı mevcut kullanıcı adıyla aynı olamaz.",
                StatusCodes.Status400BadRequest
            );
        user.UserName = request.Username;
    }

    // 5) Email kontrol
    if (!string.IsNullOrWhiteSpace(request.Email))
    {
        if (request.Email == user.Email)
            return ResponseDto<UpdateUserResponseDto>.Fail(
                "Yeni email mevcut email ile aynı olamaz.",
                StatusCodes.Status400BadRequest
            );
        user.Email = request.Email;
    }

    // 6) PhoneNumber kontrol
    if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
    {
        if (request.PhoneNumber == user.PhoneNumber)
            return ResponseDto<UpdateUserResponseDto>.Fail(
                "Yeni telefon numarası mevcut numarayla aynı olamaz.",
                StatusCodes.Status400BadRequest
            );
        user.PhoneNumber = request.PhoneNumber;
    }

    bool passwordChanged = false;

    // 7) Şifre değişimi
    if (!string.IsNullOrWhiteSpace(request.NewPassword))
    {
        if (string.IsNullOrWhiteSpace(request.CurrentPassword))
            return ResponseDto<UpdateUserResponseDto>.Fail("Mevcut şifre gerekli", StatusCodes.Status400BadRequest);

        var passwordCheck = await _userManager.CheckPasswordAsync(user, request.CurrentPassword);
        if (!passwordCheck)
            return ResponseDto<UpdateUserResponseDto>.Fail("Mevcut şifre yanlış", StatusCodes.Status401Unauthorized);

        var token = await _userManager.GeneratePasswordResetTokenAsync(user);
        var result = await _userManager.ResetPasswordAsync(user, token, request.NewPassword);

        if (!result.Succeeded)
            return ResponseDto<UpdateUserResponseDto>.Fail(result.Errors.Select(e => e.Description).ToList(), StatusCodes.Status400BadRequest);

        passwordChanged = true;

        // SecurityStamp güncelle
        await _userManager.UpdateSecurityStampAsync(user);
    }

    // 8) Şifre değişmişse yeni access ve refresh token üret
    string? accessToken = null;
    string? refreshToken = null;
    DateTime? expiration = null;

    if (passwordChanged)
    {
        IList<string> roles = await _userManager.GetRolesAsync(user);
        var jwt = await _tokenService.CreateToken(user, roles);
        accessToken = new JwtSecurityTokenHandler().WriteToken(jwt);
        expiration = jwt.ValidTo;

        refreshToken = _tokenService.GenerateRefreshToken();
        _ = int.TryParse(_configuration["JWT:RefreshTokenValidityInDays"], out int refreshTokenValidityInDays);

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(refreshTokenValidityInDays);
    }

    // 9) DB update
    var updateResult = await _userManager.UpdateAsync(user);
    if (!updateResult.Succeeded)
        return ResponseDto<UpdateUserResponseDto>.Fail(updateResult.Errors.Select(e => e.Description).ToList(), StatusCodes.Status500InternalServerError);

        // 10) Response
        var responseDto = new UpdateUserResponseDto
    {
        Token = accessToken,
        RefreshToken = refreshToken,
        Expiration = expiration
    };

    return ResponseDto<UpdateUserResponseDto>.Success(responseDto, StatusCodes.Status200OK);
}

}
