import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/base/logger.dart';
import 'package:habit_tracker_mobile/models/user_dto.dart';
import 'package:habit_tracker_mobile/screens/group_inside_screen.dart';
import 'package:habit_tracker_mobile/services/user_session_service.dart';
import 'package:habit_tracker_mobile/widgets/habit_group_form.dart';
import 'package:intl/intl.dart';
import '../models/HabitGroup/habit_group_dto.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/habit_group_service.dart';
import '../widgets/PopUp/error_response_popup.dart';
import '../widgets/PopUp/confirmation_popup.dart';

class HabitGroupsScreen extends StatefulWidget {
  const HabitGroupsScreen({super.key});

  @override
  State<HabitGroupsScreen> createState() => _HabitGroupsScreenState();
}

class _HabitGroupsScreenState extends State<HabitGroupsScreen> {
  bool _isLoading = false;
  UserDto? _user;

  final _logger = logger;

  final _authService = AuthService();
  final _habitGroupService = HabitGroupService();
  final _firebaseService = FirebaseService();

  List<HabitGroupDto> _habitGroups = [];

  String? _selectedSort;
  final List<String> _sortOptions = [
    "Tarih ▼",
    "Tarih ▲",
    "Alfabetik ▼",
    "Alfabetik ▲",
  ];


  @override
  void initState() {
    super.initState();
    getHabitGroupsAsync();
  }

  //ADD HABIT GROUP
  Future<void> _addNewGroup(String name) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });

    var response;
    try {
      response = await _habitGroupService.createHabitGroupAsync(_user!.id, name);
    }catch(err){
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          backgroundColor: Colors.red,
        ),
      );

    }
    setState(() {
      getHabitGroupsAsync();
      _isLoading = false;
    });

    if(response.isSuccess && response.statusCode == 201){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('İşlem Başarılı!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),

          ),
          backgroundColor: Colors.greenAccent,
          duration: Duration(milliseconds: 500),
        ),
      );
    }else {
      showErrorDialog(
          context: context,
          title: 'İşlem Başarısız',
          errors: response.errors ?? [response.message ?? 'Bilinmeyen bir hata oluştu.']
      );
    }
  }

  // UPDATE HABIT GROUP
  Future<void> _updateHabitGroup(String name, String habitGroupId) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _habitGroupService.updateHabitGroupAsync(
        id: habitGroupId,
        name: name,
      );

      setState(() => _isLoading = false);

      if (response.isSuccess || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Grup başarıyla güncellendi."),
            backgroundColor: Colors.greenAccent,
            duration: Duration(milliseconds: 800),
          ),
        );

        setState(() {
          _habitGroups
              .firstWhere((element) => element.id == habitGroupId)
              .name = name;
        }
        );

      } else {
        showErrorDialog(
          context: context,
          title: "Güncelleme Başarısız",
          errors: response.errors ??
              [response.message ?? "Bilinmeyen bir hata oluştu."],
        );
      }
    } catch (err) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //HABIT GROUP NAME FORM
  Future<String?> showHabitGroupNameSheet(BuildContext context) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return null;
    }

    var updatedName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitGroupForm(),
    );

    return updatedName != null && updatedName.isNotEmpty ? updatedName : null;

  }

  // LIST SORT
  void _sortHabitGroups() {
    setState(() {
      switch (_selectedSort) {
        case "Tarih ▲":
          _habitGroups.sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
          break;
        case "Tarih ▼":
          _habitGroups.sort((a, b) => a.createdDate!.compareTo(b.createdDate!));
          break;
        case "Alfabetik ▼":
          _habitGroups.sort((a, b) => a.name!.compareTo(b.name!));
          break;
        case "Alfabetik ▲":
          _habitGroups.sort((a, b) => b.name!.compareTo(a.name!));
          break;
      }
    });
  }

  // GET HABIT GROUPS
  Future<void> getHabitGroupsAsync() async{
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _user = UserSessionService().currentUser;
    final response = await _habitGroupService.getHabitGroupsOfUserAsync(_user!.id);

    if (response.isSuccess && response.data != null) {
      setState(() {
        _habitGroups = response.data?.habitGroups ?? [];
        _habitGroups.sort((a, b) => a.createdDate!.compareTo(b.createdDate!));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //DELETE HABIT GROUP
  Future<void> deleteHabitGroup(String id) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });

    var response = await _habitGroupService.deleteHabitGroup(id);

    if(response.isSuccess && response.statusCode == 200){
      _logger.i("Grup başarıyla silindi.");
      setState(() {
        _isLoading = false;
        _habitGroups.remove((group) => group.id == id);
        getHabitGroupsAsync();
      });
    }
    else {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(
          context: context,
          title: 'İşlem Başarısız',
          errors: response.errors ?? [response.message ?? 'Bilinmeyen bir hata oluştu.']
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7AAE1),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // API REQUEST AWAİT
            : Column(
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //ADD GROUP BUTTON
                  Flexible(
                    flex: 5,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          String? name = await showHabitGroupNameSheet(context);
                          _addNewGroup(name!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.black),
                            SizedBox(width: 4),
                            Text("New Group", style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //FILTER BOX
                  Flexible(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: SizedBox(
                        height: 56,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedSort,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
                            hintText: "Sort",
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          items: _sortOptions.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSort = newValue!;
                              _sortHabitGroups();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
            const SizedBox(height: 12),
            //HABIT GROUP LIST
            if (_habitGroups.isEmpty)
               Expanded(
                 child: Center(
                   child: Text(
                    "No groups found.",),
                 )
               )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _habitGroups.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemBuilder: (context, index) {
                    final group = _habitGroups[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Text(
                          group.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('dd MMMM yyyy, HH:mm').format(group.createdDate!),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.deepPurple,
                                  width: 1,
                                ),
                              ),
                              color: Colors.white,
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_horiz, color: Colors.deepPurple),
                              onSelected: (value) async {
                                if (value == 'update') {
                                  String? name = await showHabitGroupNameSheet(context);
                                  if (name != null && name.isNotEmpty) {
                                    _updateHabitGroup(name, group.id!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Grup adı boş olamaz."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else if (value == 'delete') {
                                  bool? result = await ConfirmationPopup.show(
                                      context, "Are you sure to delete this group?");
                                  if (result == true) {
                                    deleteHabitGroup(group.id!);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'update',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.deepPurple, size: 20),
                                      SizedBox(width: 8),
                                      Text('Update'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupInsideScreen(habitGroup: group)));
                        },
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
