import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../viewmodels/appointments_viewmodel.dart';
import 'appointment_entry_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();

  EventList<Event> _getMarkedDates(List<DateTime> datesWithAppointments) {
    final eventList = EventList<Event>(events: {});

    for (var date in datesWithAppointments) {
      eventList.add(
        date,
        Event(
          date: date,
          dot: Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            width: 4.0,
            height: 4.0,
          ),
        ),
      );
    }

    return eventList;
  }

  Future<void> _showAppointmentsModal(
    BuildContext context,
    DateTime date,
    AppointmentsViewModel viewModel,
  ) async {
    final appointments = await viewModel.getAppointmentsByDate(date);

    if (!mounted) return;

    if (appointments.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                DateFormat('MMMM d, yyyy').format(date),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ),
            // Appointments list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${appointment.title} (${DateFormat('h:mm a').format(appointment.date)})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (appointment.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            appointment.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsViewModel>(
      builder: (context, viewModel, child) {
        final datesWithAppointments = viewModel.getDatesWithAppointments();
        final markedDates = _getMarkedDates(datesWithAppointments);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CalendarCarousel<Event>(
              onDayPressed: (DateTime date, List<Event> events) async {
                setState(() {
                  _selectedDate = date;
                });
                await _showAppointmentsModal(context, date, viewModel);
              },
              weekendTextStyle: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              thisMonthDayBorderColor: Colors.grey,
              weekFormat: false,
              markedDatesMap: markedDates,
              height: 420.0,
              selectedDateTime: _selectedDate,
              // Dia atual sempre vermelho
              todayButtonColor: Colors.red,
              todayBorderColor: Colors.red,
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              // Dia selecionado (que não é hoje) com borda azul
              selectedDayButtonColor: Colors.transparent,
              selectedDayBorderColor: Colors.blue,
              selectedDayTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              // Bordas quadradas, não circulares
              daysHaveCircularBorder: false,
              customGridViewPhysics: const NeverScrollableScrollPhysics(),
              markedDateShowIcon: true,
              markedDateIconMaxShown: 1,
              markedDateMoreShowTotal: null,
              markedDateIconBuilder: (event) {
                return event.dot as Widget;
              },
              headerTextStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 24.0,
              ),
              weekdayTextStyle: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 14,
              ),
              iconColor: Colors.blue,
              headerMargin: const EdgeInsets.symmetric(vertical: 16.0),
              daysTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              inactiveDaysTextStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              onCalendarChanged: (DateTime date) {
                // Month changed
              },
            ),
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
              if (result == true && mounted) {
                // Reload appointments
                viewModel.loadAppointments();
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
