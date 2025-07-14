import 'package:flutter/material.dart';

class Meeting {
  final String? id;
  final String chamaId;
  final DateTime meetingDate;
  final String venue;
  final String agenda;
  final String status;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int created_by;

  Meeting({
    this.id,
    required this.chamaId,
    required this.meetingDate,
    required this.venue,
    required this.agenda,
    this.status = 'scheduled',
    this.startTime,
    this.endTime,
    required this.created_by,
  });

  Map<String, dynamic> toJson() {
    return {
      'chama_id': chamaId,
      'meeting_date': meetingDate.toIso8601String(),
      'venue': venue,
      'agenda': agenda,
      'status': status,
      'start_time':
          startTime != null
              ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
              : null,
      'end_time':
          endTime != null
              ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'

              : null,
      'created_by':created_by        
    };
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Meeting(
      id: json['id'],
      chamaId: json['chama_id'],
      meetingDate: DateTime.parse(json['meeting_date']),
      venue: json['venue'],
      agenda: json['agenda'],
      status: json['status'] ?? 'scheduled',
      startTime: parseTime(json['start_time']),
      endTime: parseTime(json['end_time']),
      created_by: json["created_by"],
    );
  }
}
