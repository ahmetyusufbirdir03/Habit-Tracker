using AutoMapper;
using Habit.Tracker.Application.Services.UtilServices;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.Auth;
using Habit.Tracker.Contracts.Dtos.User.Login;
using Habit.Tracker.Contracts.Dtos.User.Register;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System.IdentityModel.Tokens.Jwt;

namespace Habit.Tracker.Application.Services;

public class AuthService : IAuthService
{
    private readonly ErrorMessageService _errorMessageService;
    private readonly IMapper _mapper;
    private readonly IUnitOfWork _unitOfWork;
    private readonly UserManager<User> _userManager;
    private readonly ITokenService _tokenService;
    private readonly IConfiguration _configuration;
    private readonly IValidationService _validationService;
    private readonly RoleManager<Role> _roleManager;

    public AuthService(
        ErrorMessageService errorMessageService,
        IMapper mapper,
        IUnitOfWork unitOfWork,
        UserManager<User> userManager,
        ITokenService tokenService,
        IConfiguration configuration,
        IValidationService validationService,
        RoleManager<Role> roleManager)
    {
        _errorMessageService = errorMessageService;
        _mapper = mapper;
        _unitOfWork = unitOfWork;
        _userManager = userManager;
        _tokenService = tokenService;
        _configuration = configuration;
        _validationService = validationService;
        _roleManager = roleManager;
    }
    public async Task<ResponseDto<RefreshTokenResponseDto>> RefreshAccessTokenAsync(RefreshTokenDto request)
    {
        var users = await _unitOfWork.GetGenericRepository<User>().GetAllAsync(x => x.RefreshToken == request.RefreshToken);
        var user = users.FirstOrDefault();
        if (user == null)
            return ResponseDto<RefreshTokenResponseDto>
                .Fail(_errorMessageService.InvalidOrExpiredToken,StatusCodes.Status401Unauthorized);

        if (user.RefreshTokenExpiryTime <= DateTime.UtcNow)
        {
            user.RefreshToken = null;
            await _userManager.UpdateAsync(user);
            return ResponseDto<RefreshTokenResponseDto>
                .Fail(_errorMessageService.SessionExpired, StatusCodes.Status401Unauthorized);
        }

        user.SecurityStamp = Guid.NewGuid().ToString();
        IList<string> roles = await _userManager.GetRolesAsync(user);
        JwtSecurityToken newAccessToken = await _tokenService.CreateToken(user, roles);

        await _userManager.UpdateAsync(user);

        string accessToken = new JwtSecurityTokenHandler().WriteToken(newAccessToken);

        return ResponseDto<RefreshTokenResponseDto>.Success(
        new RefreshTokenResponseDto
        {
            AccessToken = accessToken,
            RefreshToken = user.RefreshToken,
            ExpirationTime = newAccessToken.ValidTo

        }, StatusCodes.Status200OK);

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

    public async Task<ResponseDto<LoginResponseDto>> LoginAsync(LoginRequestDto request)
    {
        var validationError = await _validationService.ValidateAsync<LoginRequestDto, LoginResponseDto>(request);
        if (validationError != null)
            return validationError;


        User? user = await _userManager.FindByEmailAsync(request.Email);
        if (user == null)
        {
            return ResponseDto<LoginResponseDto>.Fail(_errorMessageService.EmailNotFound, StatusCodes.Status404NotFound);
        }
        bool checkPassword = await _userManager.CheckPasswordAsync(user, request.Password);

        if (user == null || !checkPassword)
            return ResponseDto<LoginResponseDto>.Fail(_errorMessageService.InvalidAuthenticationCredentials, StatusCodes.Status401Unauthorized);

        IList<string> roles = await _userManager.GetRolesAsync(user);

        JwtSecurityToken token = await _tokenService.CreateToken(user, roles);

        user.RefreshToken = null;
        string refreshToken = _tokenService.GenerateRefreshToken();

        _ = int.TryParse(_configuration["JWT:RefreshTokenValidityInDays"], out int refreshTokenValidityInDays);

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpiryTime = DateTime.Now.AddDays(refreshTokenValidityInDays);
        user.SecurityStamp = Guid.NewGuid().ToString();

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
}
