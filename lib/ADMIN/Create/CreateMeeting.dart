import 'package:flutter/material.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:intl/intl.dart';

class CreateMeetingForm extends StatefulWidget {
  const CreateMeetingForm({Key? key}) : super(key: key);

  @override
  State<CreateMeetingForm> createState() => _CreateMeetingFormState();
}

class _CreateMeetingFormState extends State<CreateMeetingForm> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _agendaController = TextEditingController();
  // final _meetingService = MeetingService();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedStatus = 'scheduled';
  bool _isLoading = false;

  final List<String> _statusOptions = ['scheduled', 'in_progress', 'completed'];

  @override
  void dispose() {
    _venueController.dispose();
    _agendaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Clear end time if it's before start time
        if (_endTime != null && _isEndTimeBeforeStartTime(picked, _endTime!)) {
          _endTime = null;
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select start time first'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1))
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (_isEndTimeBeforeStartTime(_startTime!, picked)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('End time cannot be before start time'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      setState(() {
        _endTime = picked;
      });
    }
  }

  bool _isEndTimeBeforeStartTime(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes <= startMinutes;
  }

  DateTime? get _meetingStartDateTime {
    if (_selectedDate == null || _startTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  DateTime? get _meetingEndDateTime {
    if (_selectedDate == null || _endTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate() || 
        _selectedDate == null || 
        _startTime == null || 
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields including start and end times'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final meeting = Meeting(
      chamaId: user.chamaId.toString(),
      meetingDate: _meetingStartDateTime!,
      venue: _venueController.text.trim(),
      agenda: _agendaController.text.trim(),
      status: _selectedStatus,
      startTime: _startTime,
      endTime: _endTime,
      created_by: user.id
    );

    try {
      final result = await comms.postRequest(
        endpoint: "meeting",
        data: meeting.toJson(),
      );

      if (result["rsp"]["success"]) {
        setState(() => _isLoading = false);
        showalert(
          success: true,
          context: context,
          title: "Success",
          subtitle: "Meeting created for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)} successfully",
        );
        Navigator.pop(context);
      } else {
        setState(() => _isLoading = false);
        showalert(
          success: false,
          context: context,
          title: "Failed",
          subtitle: result["rsp"]["message"],
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Meeting Date Selection
                Card(
                  elevation: 2,
                  color: theme.colorScheme.surface,
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meeting Date',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedDate == null
                                      ? 'Select date'
                                      : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _selectedDate == null
                                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Time Selection Row
                Row(
                  children: [
                    // Start Time
                    Expanded(
                      child: Card(
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: InkWell(
                          onTap: _selectStartTime,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Start Time',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _startTime == null
                                      ? 'Select time'
                                      : _startTime!.format(context),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _startTime == null
                                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // End Time
                    Expanded(
                      child: Card(
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: InkWell(
                          onTap: _selectEndTime,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'End Time',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _endTime == null
                                      ? 'Select time'
                                      : _endTime!.format(context),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _endTime == null
                                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Venue Field
                TextFormField(
                  controller: _venueController,
                  decoration: InputDecoration(
                    labelText: 'Venue',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a venue';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(
                      Icons.flag,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Agenda Field
                TextFormField(
                  controller: _agendaController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Agenda',
                    prefixIcon: Icon(
                      Icons.list_alt,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the meeting agenda';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Create Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _createMeeting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Create Meeting',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}