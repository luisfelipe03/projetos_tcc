import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../viewmodels/appointments_viewmodel.dart';
import '../models/appointment_model.dart';
import 'appointment_entry_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _selectedDayAppointments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSelectedDayAppointments();
    });
  }

  Future<void> _loadSelectedDayAppointments() async {
    final viewModel = context.read<AppointmentsViewModel>();
    final appointments = await viewModel.getAppointmentsByDate(_selectedDate);
    setState(() {
      _selectedDayAppointments = appointments;
    });
  }

  EventList<Event> _getMarkedDates(List<DateTime> datesWithAppointments) {
    final eventList = EventList<Event>(events: {});
    
    for (var date in datesWithAppointments) {
      eventList.add(
        date,
        Event(
          date: date,
          dot: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            width: 5.0,
            height: 5.0,
          ),
        ),
      );
    }
    
    return eventList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsViewModel>(
      builder: (context, viewModel, child) {
        final datesWithAppointments = viewModel.getDatesWithAppointments();
        final markedDates = _getMarkedDates(datesWithAppointments);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Column(
            children: [
              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CalendarCarousel<Event>(
                  onDayPressed: (DateTime date, List<Event> events) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _loadSelectedDayAppointments();
                  },
                  weekendTextStyle: const TextStyle(
                    color: Colors.red,
                  ),
                  thisMonthDayBorderColor: Colors.grey,
                  weekFormat: false,
                  markedDatesMap: markedDates,
                  height: 420.0,
                  selectedDateTime: _selectedDate,
                  todayButtonColor: Colors.red,
                  todayBorderColor: Colors.red,
                  selectedDayButtonColor: Colors.transparent,
                  selectedDayBorderColor: AppColors.primary,
                  selectedDayTextStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  daysHaveCircularBorder: true,
                  customGridViewPhysics: const NeverScrollableScrollPhysics(),
                  markedDateShowIcon: true,
                  markedDateIconMaxShown: 1,
                  markedDateMoreShowTotal: null,
                  markedDateIconBuilder: (event) {
                    return event.dot as Widget;
                  },
                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  headerTextStyle: const TextStyle(
                    color: Colors.blue,
                    fontSize: 24.0,
                  ),
                  weekdayTextStyle: const TextStyle(
                    color: Colors.deepOrange,
                  ),
                  iconColor: Colors.blue,
                  headerMargin: const EdgeInsets.symmetric(vertical: 16.0),
                  daysTextStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  onCalendarChanged: (DateTime date) {
                    // Month changed
                  },
                ),
              ),
              const Divider(height: 1),
              // Appointments list for selected day
              Expanded(
                child: _selectedDayAppointments.isEmpty
                    ? Center(
                        child: Text(
                          'No appointments for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _selectedDayAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _selectedDayAppointments[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                appointment.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (appointment.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        appointment.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      DateFormat('h:mm a').format(appointment.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AppointmentEntryScreen(
                                            appointment: appointment,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadSelectedDayAppointments();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Appointment'),
                                          content: const Text(
                                            'Are you sure you want to delete this appointment?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await viewModel.deleteAppointment(
                                          appointment.id,
                                        );
                                        _loadSelectedDayAppointments();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentEntryScreen(
                    initialDate: _selectedDate,
                  ),
                ),
              );
              if (result == true) {
                _loadSelectedDayAppointments();
              }
            },
            backgroundColor: AppColors.secondary,
            elevation: 4,
            child: const Icon(Icons.add, color: AppColors.background),
          ),
        );
      },
    );
  }
}
