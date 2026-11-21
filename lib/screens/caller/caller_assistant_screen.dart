import 'package:flutter/material.dart';

import '../../services/appointment_service.dart';
import '../../services/caller_assistant_service.dart';

class CallerAssistantScreen extends StatefulWidget {
  const CallerAssistantScreen({super.key});

  @override
  State<CallerAssistantScreen> createState() => _CallerAssistantScreenState();
}

class _CallerAssistantScreenState extends State<CallerAssistantScreen>
    with SingleTickerProviderStateMixin {
  final AppointmentService appointments = AppointmentService.instance;
  final CallerAssistantService calls = CallerAssistantService.instance;
  late final TabController tabs;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 2, vsync: this);
    appointments.init();
    calls.init().then((_) {
      if (calls.optedIn) calls.loadRecentCalls();
    });
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  Future<void> _edit({AppointmentItem? existing, CallLogEntry? call}) async {
    final title = TextEditingController(
      text: existing?.title ?? (call == null ? '' : 'Call follow-up'),
    );
    final caller = TextEditingController(text: existing?.callerName ?? call?.name ?? '');
    final phone = TextEditingController(text: existing?.phoneNumber ?? call?.number ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    DateTime scheduled = existing?.scheduledAt ?? DateTime.now().add(const Duration(hours: 1));

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF141522),
          title: Text(existing == null ? 'Create appointment' : 'Edit appointment',
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: title, style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: caller, style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Caller name')),
                TextField(controller: phone, style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Phone number')),
                TextField(controller: notes, style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
                ListTile(
                  title: Text(scheduled.toLocal().toString(),
                      style: const TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.schedule, color: Colors.deepPurpleAccent),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: scheduled,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: dialogContext,
                      initialTime: TimeOfDay.fromDateTime(scheduled),
                    );
                    if (time != null) {
                      setDialogState(() {
                        scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved == true && title.text.trim().isNotEmpty) {
      if (existing == null) {
        await appointments.add(
          title: title.text,
          callerName: caller.text,
          phoneNumber: phone.text,
          scheduledAt: scheduled,
          notes: notes.text,
        );
      } else {
        await appointments.update(existing.copyWith(
          title: title.text,
          callerName: caller.text,
          phoneNumber: phone.text,
          scheduledAt: scheduled,
          notes: notes.text,
        ));
      }
    }
    title.dispose();
    caller.dispose();
    phone.dispose();
    notes.dispose();
  }

  Future<void> _notifyAppointment(AppointmentItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF141522),
        title: const Text('Send appointment summary?'),
        content: Text(appointments.formatTelegramSummary(item),
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Send Telegram')),
        ],
      ),
    );
    if (confirmed != true) return;
    final message = await appointments.sendTelegramSummary(item.id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendCall(CallLogEntry call) async {
    final draft = calls.formatCallSummary(call);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF141522),
        title: const Text('Send call summary?'),
        content: Text(draft, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Send Telegram')),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await calls.sendTelegramSummary(call);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  Future<void> _createFromCall(CallLogEntry call) => _edit(call: call);

  Widget _appointmentsTab() {
    return AnimatedBuilder(
      animation: appointments,
      builder: (context, _) {
        final list = appointments.appointments;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ElevatedButton.icon(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('New appointment'),
            ),
            for (final item in list)
              Card(
                color: const Color(0xFF141522),
                child: ListTile(
                  title: Text(item.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    [item.callerName, item.phoneNumber, item.scheduledAt.toLocal().toString(), item.status.name]
                        .where((value) => value.isNotEmpty)
                        .join(' • '),
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          await _edit(existing: item);
                          break;
                        case 'confirm':
                          await appointments.setStatus(item.id, AppointmentStatus.confirmed);
                          break;
                        case 'complete':
                          await appointments.setStatus(item.id, AppointmentStatus.completed);
                          break;
                        case 'export':
                          await appointments.exportToCalendar(item.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Exported to Calendar reminders')),
                            );
                          }
                          break;
                        case 'telegram':
                          await _notifyAppointment(item);
                          break;
                        case 'delete':
                          await appointments.delete(item.id);
                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'confirm', child: Text('Confirm')),
                      PopupMenuItem(value: 'complete', child: Text('Complete')),
                      PopupMenuItem(value: 'export', child: Text('Export to Calendar')),
                      PopupMenuItem(value: 'telegram', child: Text('Send Telegram summary')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _callTriageTab() {
    return AnimatedBuilder(
      animation: calls,
      builder: (context, _) {
        if (!calls.optedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_missed_outgoing, color: Color(0xFF5E4AE3), size: 42),
                  const SizedBox(height: 12),
                  const Text('Call triage is opt-in', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const Text(
                    'JARVIS only reads recent call metadata after you enable it and grant Android Call Log permission. No call audio is accessed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final granted = await calls.requestCallLogPermission();
                      if (!granted) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Call Log permission was not granted')),
                          );
                        }
                        return;
                      }
                      await calls.setOptedIn(true);
                      await calls.loadRecentCalls();
                    },
                    child: const Text('Enable Call Triage'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(child: Text('Recent calls (metadata only)', style: TextStyle(color: Colors.white70))),
                  IconButton(onPressed: calls.loadRecentCalls, icon: const Icon(Icons.refresh, color: Colors.white)),
                  TextButton(onPressed: () => calls.setOptedIn(false), child: const Text('Disable')),
                ],
              ),
            ),
            if (calls.loading) const LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: calls.recentCalls.length,
                itemBuilder: (context, index) {
                  final call = calls.recentCalls[index];
                  return Card(
                    color: const Color(0xFF141522),
                    child: ListTile(
                      leading: Icon(call.isMissed ? Icons.call_missed : Icons.call,
                          color: call.isMissed ? Colors.orange : const Color(0xFF5E4AE3)),
                      title: Text(call.name.isEmpty ? call.number : call.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(call.number + ' • ' + call.callTime.toLocal().toString(),
                          style: const TextStyle(color: Colors.white60)),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'appointment') _createFromCall(call);
                          if (value == 'telegram') _sendCall(call);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'appointment', child: Text('Create appointment')),
                          PopupMenuItem(value: 'telegram', child: Text('Draft & send Telegram summary')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const panel = Color(0xFF141522);
    const accent = Color(0xFF5E4AE3);
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: panel,
        title: const Text('JARVIS PRO • Caller & Appointments'),
        bottom: TabBar(
          controller: tabs,
          indicatorColor: accent,
          tabs: const [Tab(text: 'Appointments'), Tab(text: 'Call Triage')],
        ),
      ),
      body: TabBarView(controller: tabs, children: [_appointmentsTab(), _callTriageTab()]),
    );
  }
}
