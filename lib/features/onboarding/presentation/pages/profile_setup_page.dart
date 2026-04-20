import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/profile_service.dart';
import '../../../todo/presentation/pages/main_page.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_event.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_state.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_form_bloc/profile_form_bloc.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_form_bloc/profile_form_event.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_form_bloc/profile_form_state.dart';
import '../../../../core/services/service_locator.dart';

class ProfileSetupPage extends StatefulWidget {
  final bool isEditing;
  final String heroTag;
  const ProfileSetupPage({super.key, this.isEditing = false, this.heroTag = 'profile_avatar'});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  late ProfileFormBloc _formBloc;

  @override
  void initState() {
    super.initState();
    _formBloc = sl<ProfileFormBloc>();
    final pState = context.read<ProfileBloc>().state;
    if (pState is ProfileLoaded) {
      final p = pState.profile;
      _nameController.text = p.name;
      _ageController.text = p.age.toString();
      _formBloc.add(InitializeProfileFormEvent(p));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _formBloc.add(ImageChangedEvent(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  void _completeSetup(ProfileFormState state) {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: state.gender,
        imagePath: state.imagePath,
      );

      context.read<ProfileBloc>().add(UpdateProfileEvent(profile));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _formBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            if (widget.isEditing) {
              Navigator.pop(context, true);
            } else {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainPage()), (route) => false);
            }
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ProfileFormBloc, ProfileFormState>(
          builder: (context, formState) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.isEditing ? 'Edit Profile' : 'Setup Profile'), centerTitle: true),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(widget.isEditing ? 'Update Your Profile' : 'Tell us about yourself', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      if (!widget.isEditing)
                        const Text('This information will help us personalize your experience.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                      const SizedBox(height: 48),
                      Center(
                        child: Stack(
                          children: [
                            Hero(
                              tag: widget.heroTag,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                  image: formState.imagePath != null ? DecorationImage(image: FileImage(File(formState.imagePath!)), fit: BoxFit.cover) : null,
                                ),
                                child: formState.imagePath == null ? Icon(Icons.person_rounded, size: 80, color: theme.colorScheme.outline) : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                                  child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Full Name', prefixIcon: const Icon(Icons.badge_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'Age', prefixIcon: const Icon(Icons.calendar_month_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Age?';
                                if (int.tryParse(v) == null) return 'Int';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: formState.gender,
                              decoration: InputDecoration(labelText: 'Gender', prefixIcon: const Icon(Icons.wc_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                              items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (v) => _formBloc.add(GenderChangedEvent(v!)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, pState) {
                          return FilledButton.icon(
                            onPressed: pState is ProfileLoading ? null : () => _completeSetup(formState),
                            icon: pState is ProfileLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check_circle_outline),
                            label: Text(pState is ProfileLoading ? 'Saving...' : (widget.isEditing ? 'Save Changes' : 'Complete Setup')),
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
