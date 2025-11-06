using AutoMapper;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.HabitGroup;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Create;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Update;
using Habit.Tracker.Contracts.Interfaces;
using Habit.Tracker.Contracts.Interfaces.Services;
using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Http;

namespace Habit.Tracker.Application.Services;

public class HabitGroupService : IHabitGroupService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ErrorMessageService _errorMessageService;
    private readonly IValidationService _validationService;

    public HabitGroupService(
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
    public async Task<ResponseDto<NoContentDto>> CreateHabitGroup(HabitGroupCreateRequestDto request)
    {
        //REQUEST NULL CHECK
        if (request == null)
            return ResponseDto<NoContentDto>.Fail("NoRequest",StatusCodes.Status400BadRequest);

        // USER ID CHECK
        User? user = await _unitOfWork.GetGenericRepository<User>().GetByIdAsync(request.UserId);

        if (user is null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

        // GROUP NAME CHECK
        bool isNameExist = await _unitOfWork.GetGenericRepository<HabitGroup>().AnyAsync(x => x.Name == request.Name && x.Id == request.UserId);
        
        if(isNameExist)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitGroupNameAlreadyExists, StatusCodes.Status400BadRequest);


        // CREATE GROUP
        HabitGroup habitGroup = _mapper.Map<HabitGroup>(request);

        habitGroup.Id = Guid.NewGuid();
        habitGroup.CreatedDate = DateTime.UtcNow;
        habitGroup.Habits = new List<HabitEntity>();
        habitGroup.CreatedBy = user.Id.ToString();

        await _unitOfWork.GetGenericRepository<HabitGroup>().CreateAsync(habitGroup);

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status201Created);
    }

    public async Task<ResponseDto<NoContentDto>> DeleteHabitGroup(Guid id)
    {
        var habitGroup = await _unitOfWork.GetGenericRepository<HabitGroup>().GetByIdAsync(id);
        if(habitGroup is null) 
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitGroupNotFound, StatusCodes.Status404NotFound);

        await _unitOfWork.GetGenericRepository<HabitGroup>().DeleteAsync(habitGroup);
        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);

    }

    public async Task<ResponseDto<IList<HabitGroupResponseDto>>> GetAllHabitGroups()
    {
        var habitGroups = await _unitOfWork.GetGenericRepository<HabitGroup>().GetAllAsync();
        if (!habitGroups.Any())
            return ResponseDto<IList<HabitGroupResponseDto>>.Fail(_errorMessageService.HabitGroupNotFound, StatusCodes.Status404NotFound);

        IList<HabitGroupResponseDto> _habitGroups = _mapper.Map<IList<HabitGroupResponseDto>>(habitGroups);

        return ResponseDto<IList<HabitGroupResponseDto>>.Success(_habitGroups, StatusCodes.Status200OK);

    }

    public async Task<ResponseDto<IList<HabitGroupResponseDto>>> GetAllHabitGroupsByUserId(Guid Id)
    {
        //USER CHECK
        var user = await _unitOfWork.GetGenericRepository<HabitGroup>().AnyAsync(h => h.UserId == Id);
        if (!user)
            return ResponseDto<IList<HabitGroupResponseDto>>.Fail(_errorMessageService.UserNotFound, StatusCodes.Status404NotFound);

        //GROUPS CHECK
        var habitGroups = await _unitOfWork.GetGenericRepository<HabitGroup>().GetAllAsync(x => x.UserId == Id);
        if (!habitGroups.Any())
            return ResponseDto<IList<HabitGroupResponseDto>>.Fail(_errorMessageService.HabitGroupNotFound, StatusCodes.Status404NotFound);

        IList<HabitGroupResponseDto> _habitGroups = _mapper.Map<IList<HabitGroupResponseDto>>(habitGroups);

        return ResponseDto<IList<HabitGroupResponseDto>>.Success(_habitGroups, StatusCodes.Status200OK);
    }

    public async Task<ResponseDto<NoContentDto>> UpdateHabitGroup(UpdateHabitGroupRequestDto request)
    {
        //VALIDATIONS
        var validationError = await _validationService.ValidateAsync<UpdateHabitGroupRequestDto, NoContentDto>(request);
        if (validationError != null)
            return validationError;

        //HABIT GROUP CHECK
        var habitGroup = await _unitOfWork.GetGenericRepository<HabitGroup>().GetByIdAsync(request.Id);
        if(habitGroup is null)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitGroupNotFound,StatusCodes.Status404NotFound);

        if (habitGroup.Name == request.Name)
            return ResponseDto<NoContentDto>.Fail(_errorMessageService.HabitGroupWithSameNameExists, StatusCodes.Status400BadRequest);

        habitGroup.Name = request.Name;
        habitGroup.UpdatedDate = DateTime.UtcNow;
        _= await _unitOfWork.GetGenericRepository<HabitGroup>().UpdateAsync(habitGroup);

        return ResponseDto<NoContentDto>.Success(StatusCodes.Status200OK);
    }
}
