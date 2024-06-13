import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:khms/Controller/dashboardController.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController _controller = DashboardController();
  String? _selectedBlock;
  Future<Map<String, dynamic>>? _blockDataFuture;
  Future<Map<String, dynamic>>? _generalDataFuture;

  @override
  void initState() {
    super.initState();
    _generalDataFuture = _controller.fetchDashboardData();
  }

  Future<void> _showBlockSelectionDialog() async {
    final selectedBlock = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Block'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Block A');
              },
              child: const Text('Block A'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Block B');
              },
              child: const Text('Block B'),
            ),
          ],
        );
      },
    );

    if (selectedBlock != null) {
      setState(() {
        _selectedBlock = selectedBlock;
        _blockDataFuture = _controller.fetchBlockData(selectedBlock);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final tab in [
                'Check-Ins',
                'Check-Outs',
                'Facilities',
                'Complaints',
                'Blocks'
              ])
                Tab(
                  text: tab,
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Check-Ins Tab
            SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder(
                    future: _generalDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return Column(
                          children: [
                            _buildSummaryCard('Total Check-In Applications',
                                data['totalCheckInApplications']),
                            _buildSummaryCard('Pending Check-In Applications',
                                data['pendingCheckInApplications']),
                            _buildBarChart('Check-In Applications by Room Type',
                                data['checkInApplicationsByRoomType']),
                          ],
                        );
                      } else {
                        return const Center(child: Text('No data available'));
                      }
                    },
                  ),
                ],
              ),
            ),

            SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder(
                    future: _generalDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return Column(
                          children: [
                            _buildSummaryCard('Total Check-Out Applications',
                                data['totalCheckOutApplications']),
                            _buildSummaryCard('Pending Check-Out Applications',
                                data['pendingCheckOutApplications']),
                          ],
                        );
                      } else {
                        return const Center(child: Text('No data available'));
                      }
                    },
                  ),
                ],
              ),
            ),

            // Facilities Tab
            SingleChildScrollView(
              child: FutureBuilder(
                future: _generalDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Column(
                      children: [
                        _buildSummaryCard('Total Facility Bookings',
                            data['totalFacilityBookings']),
                        _buildSummaryCard('Pending Facility Bookings',
                            data['pendingFacilityBookings']),
                        _buildBarChart('Facility Bookings by Type',
                            data['facilityBookingsByType']),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
            ),

            // Complaints Tab
            SingleChildScrollView(
              child: FutureBuilder(
                future: _generalDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Column(
                      children: [
                        _buildSummaryCard(
                            'Total Complaints', data['totalComplaints']),
                        _buildSummaryCard(
                            'Pending Complaints', data['pendingComplaints']),
                        _buildBarChart(
                            'Complaints by Type', data['complaintsByType']),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No data available'));
                  }
                },
              ),
            ),

            // Blocks Tab
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showBlockSelectionDialog,
                    child: Text(_selectedBlock ?? 'Select Block'),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedBlock != null)
                    FutureBuilder(
                      future: _blockDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return _buildBlockDetails(data, _selectedBlock!);
                        } else {
                          return const Center(child: Text('No data available'));
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value.toString(), style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockDetails(Map<String, dynamic> data, String blockName) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard('Total Rooms', (data['totalRooms'])),
        _buildSummaryCard('Occupied Rooms', data['occupiedRooms']),
        _buildSummaryCard('Available Single Rooms',
            data['availableRoomsByType']['Single'] ?? 0),
        _buildSummaryCard('Available Double Rooms',
            data['availableRoomsByType']['Double'] ?? 0),
        _buildSummaryCard('Available Triple Rooms',
            data['availableRoomsByType']['Triple'] ?? 0),
      ],
    );
  }

  Widget _buildBarChart(String title, Map<String, int> data) {
    final List<BarChartGroupData> barGroups = data.entries.map((entry) {
      return BarChartGroupData(
        x: data.keys.toList().indexOf(entry.key), // X-axis position (index)
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(), // Y-axis value (count)
            color: Colors.blue, // Bar color (customize as needed)
            width: 22,
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            AspectRatio(
              // Adjust aspect ratio as needed
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            data.keys
                                .toList()[value.toInt()], // Show category label
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(), // Show count on left axis
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
