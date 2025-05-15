import 'package:asesmen_paud/api/dto/student_dto.dart';
import 'package:asesmen_paud/api/exception.dart';
import 'package:asesmen_paud/api/payload/student_payload.dart';
import 'package:asesmen_paud/api/response.dart';
import 'package:asesmen_paud/api/service/student_service.dart';
import 'package:asesmen_paud/enum/student_enum.dart';
import 'package:asesmen_paud/widget/assessment/expanded_dropdown.dart';
import 'package:asesmen_paud/widget/assessment/expanded_text_field.dart';
import 'package:asesmen_paud/widget/assessment/photo_manager.dart';
import 'package:asesmen_paud/widget/color_snackbar.dart';
import 'package:asesmen_paud/widget/student/date_picker_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditStudentPage extends StatefulWidget {
  final Student student;

  const EditStudentPage({super.key, required this.student});

  @override
  State<EditStudentPage> createState() => EditStudentPageState();
}

class EditStudentPageState extends State<EditStudentPage> {
  List<Classroom> _classes = [];
  late int _studentId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nisnController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _acceptanceDateController =
      TextEditingController();
  XFile? _image;

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String? _selectedReligion;
  DateTime? _selectedAcceptanceDate;
  Classroom? _selectedClass;
  String? _initialImageUrl;

  bool _isLoading = false;
  bool _isClassLoading = false;
  bool isImageChanged = false;
  String? _nameError;
  String? _nisnError;
  String? _placeOfBirthError;
  String? _dateOfBirthError;
  String? _genderError;
  String? _religionError;
  String? _acceptanceDateError;
  String? _classError;
  String? _photoError;

  Future<void> _loadClasses() async {
    setState(() {
      _isClassLoading = true;
    });

    try {
      final response = await StudentService().getAllTeacherClass();
      final classes = response.payload!;

      final matchedClass = classes.firstWhere(
        (c) => c.name == widget.student.className,
        orElse: () => classes.first,
      );

      setState(() {
        _classes = response.payload!;
        _selectedClass = matchedClass;
      });
    } catch (e) {
      setState(() {
        _classError = 'Gagal memuat kelas';
      });
    } finally {
      setState(() {
        _isClassLoading = false;
      });
    }
  }

  bool _validateInputs() {
    bool hasError = false;

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = 'Nama harus diisi';
      });
      hasError = true;
    }

    if (_nisnController.text.isEmpty) {
      setState(() {
        _nisnError = 'NISN harus diisi';
      });
      hasError = true;
    }

    if (_placeOfBirthController.text.isEmpty) {
      setState(() {
        _placeOfBirthError = 'Tempat lahir harus diisi';
      });
      hasError = true;
    }

    if (_selectedDateOfBirth == null) {
      setState(() {
        _dateOfBirthError = 'Tanggal lahir harus diisi';
      });
      hasError = true;
    }

    if (_selectedGender == null) {
      setState(() {
        _genderError = 'Jenis kelamin harus diisi';
      });
      hasError = true;
    }

    if (_selectedReligion == null) {
      setState(() {
        _religionError = 'Agama harus diisi';
      });
      hasError = true;
    }

    if (_selectedAcceptanceDate == null) {
      setState(() {
        _acceptanceDateError = 'Tanggal penerimaan harus diisi';
      });
      hasError = true;
    }

    if (isImageChanged && _image == null) {
      setState(() {
        _photoError = 'Foto harus diisi';
      });
      hasError = true;
    }

    return hasError;
  }

  Future<void> _submit(int studentId) async {
    setState(() {
      _isLoading = true;
      _nameError = null;
      _nisnError = null;
      _placeOfBirthError = null;
      _dateOfBirthError = null;
      _genderError = null;
      _religionError = null;
      _acceptanceDateError = null;
      _photoError = null;
    });

    if (_validateInputs()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final dto = EditStudentDto(
      name: _nameController.text,
      nisn: _nisnController.text,
      placeOfBirth: _placeOfBirthController.text,
      dateOfBirth: DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
      gender: _selectedGender!,
      religion: _selectedReligion!,
      acceptanceDate: DateFormat('yyyy-MM-dd').format(_selectedAcceptanceDate!),
      classId: _selectedClass!.id,
      photo: _image,
    );

    try {
      final SuccessResponse<Student> response =
          await StudentService().editStudent(studentId, dto);

      if (response.status == 'success') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(ColorSnackbar.build(
          message: response.message,
          success: true,
        ));
        Navigator.pop(context);
      }
    } on ValidationException catch (e) {
      setState(() {
        _nameError = e.errors['name']?.message ?? '';
        _nisnError = e.errors['nisn']?.message ?? '';
        _placeOfBirthError = e.errors['placeOfBirth']?.message ?? '';
        _dateOfBirthError = e.errors['dateOfBirth']?.message ?? '';
        _genderError = e.errors['gender']?.message ?? '';
        _religionError = e.errors['religion']?.message ?? '';
        _acceptanceDateError = e.errors['acceptanceDateError']?.message ?? '';
        _classError = e.errors['classId']?.message ?? '';
        _photoError = e.errors['photoProfileLink']?.message ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(ColorSnackbar.build(
        message: e.toString(),
        success: false,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _studentId = widget.student.id;
    _nameController.text = widget.student.name;
    _nisnController.text = widget.student.nisn;
    _placeOfBirthController.text = widget.student.placeOfBirth ?? '';
    _dateOfBirthController.text = widget.student.dateOfBirth!;
    if (widget.student.dateOfBirth != null) {
      DateTime initialDateOfBirth = DateTime.parse(widget.student.dateOfBirth!);
      _dateOfBirthController.text =
          DateFormat('dd-MM-yyyy').format(initialDateOfBirth);
      _selectedDateOfBirth = initialDateOfBirth;
    }
    if (widget.student.acceptanceDate != null) {
      DateTime initialAcceptanceDate =
          DateTime.parse(widget.student.acceptanceDate!);
      _acceptanceDateController.text =
          DateFormat('dd-MM-yyyy').format(initialAcceptanceDate);
      _selectedAcceptanceDate = initialAcceptanceDate;
    }
    _selectedGender = widget.student.gender;
    _selectedReligion = widget.student.religion;
    _initialImageUrl = widget.student.photoProfileLink;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah data murid'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name
              ExpandedTextField(
                controller: _nameController,
                labelText: 'Nama',
                errorText: _nameError,
              ),
              const SizedBox(
                height: 20,
              ),

              // NISN
              ExpandedTextField(
                controller: _nisnController,
                labelText: 'NISN',
                errorText: _nisnError,
                enabled: false,
              ),
              const SizedBox(
                height: 20,
              ),

              // Place of Birth
              ExpandedTextField(
                controller: _placeOfBirthController,
                labelText: 'Tempat Lahir',
                errorText: _placeOfBirthError,
              ),

              const SizedBox(
                height: 20,
              ),

              // Date of Birth
              DatePickerTextField(
                controller: _dateOfBirthController,
                labelText: 'Tanggal Lahir',
                initialDate: _selectedDateOfBirth ??
                    DateTime.now().subtract(
                      const Duration(days: 365 * 4),
                    ),
                firstDate: DateTime(2000, 1, 1),
                lastDate: DateTime.now(),
                errorText: _dateOfBirthError,
                onDateSelected: (picked) {
                  setState(() {
                    _selectedDateOfBirth = picked;
                    _dateOfBirthController.text =
                        DateFormat('dd-MM-yyyy').format(picked);
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              ExpandedDropdown<String>(
                label: 'Jenis Kelamin',
                items: gender,
                selectedItem: _selectedGender,
                errorText: _genderError,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              ExpandedDropdown<String>(
                label: 'Agama',
                items: religion,
                selectedItem: _selectedReligion,
                errorText: _religionError,
                onChanged: (value) {
                  setState(() {
                    _selectedReligion = value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // Acceptance Date
              DatePickerTextField(
                controller: _acceptanceDateController,
                labelText: 'Tanggal Penerimaan',
                initialDate: _selectedAcceptanceDate ?? DateTime.now(),
                firstDate: DateTime(2014, 6, 5),
                lastDate: DateTime.now(),
                errorText: _acceptanceDateError,
                onDateSelected: (picked) {
                  setState(() {
                    _selectedAcceptanceDate = picked;
                    _acceptanceDateController.text =
                        DateFormat('dd-MM-yyyy').format(picked);
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // Class ID
              if (_isClassLoading)
                const CircularProgressIndicator()
              else
                ExpandedDropdown<Classroom>(
                  label: 'Kelas',
                  items: _classes,
                  selectedItem: _selectedClass,
                  itemLabel: (item) => item?.name,
                  errorText: _classError,
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                    });
                  },
                ),

              const SizedBox(
                height: 20,
              ),

              // Photo
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Foto',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              PhotoManager(
                  mode: PhotoMode.edit,
                  initialImageUrl: _initialImageUrl,
                  onImageSelected: (image) {
                    setState(() {
                      _image = image;
                      isImageChanged = true;
                    });
                  }),
              if (_photoError != null)
                Text(
                  _photoError!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),

              // Submit
              ElevatedButton(
                onPressed: () {
                  _submit(_studentId);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 40),
                  backgroundColor: Colors.deepPurple,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const Text(
                        'Ubah Data Murid',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
