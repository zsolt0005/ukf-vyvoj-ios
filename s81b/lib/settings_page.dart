import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_data_provider.dart';
import 'utils/helper_functions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<String?> _selectDate(BuildContext context) async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (dt != null) {
      return getFormattedDateTime(dt.millisecondsSinceEpoch);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) => ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            Text(
              'Time Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(provider.startTime),
                    trailing: IconButton(
                      onPressed: () async {
                        final date = await _selectDate(context);
                        if (date != null) provider.setStartTime(date);
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(provider.endTime),
                    trailing: IconButton(
                      onPressed: () async {
                        final date = await _selectDate(context);
                        if (date != null) provider.setEndTime(date);
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        provider.getEarthquakeData();
                        showMsg(context, 'Times are updated');
                      },
                      child: const Text('Update Time Changes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Location Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: SwitchListTile(
                title: Text(
                  provider.currentCity == null
                      ? 'Show earthquakes near me'
                      : 'Near ${provider.currentCity}',
                ),
                subtitle: Text(
                  'Only earthquakes within ${provider.shouldUseLocation ? '300' : '20001'} km',
                ),
                value: provider.shouldUseLocation,
                onChanged: (value) async {
                  final error = await provider.setLocation(value);
                  if (error != null && context.mounted) {
                    showMsg(context, error);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
