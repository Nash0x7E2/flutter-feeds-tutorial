import 'package:feeds_tutorial/activity_item.dart';
import 'package:feeds_tutorial/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:stream_feed/stream_feed.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    Key? key,
    required this.streamUser,
  }) : super(key: key);

  final User streamUser;

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late final StreamFeedClient _client;
  bool _isLoading = true;
  List<Activity> activities = <Activity>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _client = context.client; //
    _loadActivities();
  }

  Future<void> _loadActivities({bool pullToRefresh = false}) async {
    if (!pullToRefresh) setState(() => _isLoading = true);

    final userFeed =
        _client.flatFeed('timeline', widget.streamUser.id!); //Modified
    final data = await userFeed.getActivities();

    if (!pullToRefresh) _isLoading = false;
    setState(() => activities = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadActivities(pullToRefresh: true),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : activities.isEmpty
                ? Column(
                    children: [
                      Text('No activities yet!'),
                      ElevatedButton(
                        onPressed: _loadActivities,
                        child: Text('Reload'),
                      )
                    ],
                  )
                : ListView.separated(
                    itemCount: activities.length,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final activity = activities[index];
                      return ActivityCard(activity: activity);
                    },
                  ),
      ),
    );
  }
}
