// ignore_for_file: library_private_types_in_public_api

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
        child: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )),
      body: FutureBuilder(
        future: _controller.fetchDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              // Make the dashboard scrollable
              child: Column(
                children: [
                  _buildSummaryCard(
                      'Total Check-Outs', data['totalCheckOutApplications']),
                  _buildSummaryCard('Pending Check-Outs',
                      data['pendingCheckOutApplications']),
                  _buildSummaryCard(
                      'Total Facility Bookings', data['totalFacilityBookings']),
                  _buildSummaryCard('Pending Facility Bookings',
                      data['pendingFacilityBookings']),
                  _buildSummaryCard(
                      'Total Complaints', data['totalComplaints']),
                  _buildSummaryCard(
                      'Pending Complaints', data['pendingComplaints']),
                  _buildSummaryCard('Total Rooms', data['totalRooms']),
                  _buildSummaryCard('Occupied Rooms', data['occupiedRooms']),
                  _buildSummaryCard('Available Rooms', data['availableRooms']),
                  _buildSummaryCard('Single Rooms Available',
                      data['availableRoomsByType']['Single']),
                  _buildSummaryCard('Double Rooms Available',
                      data['availableRoomsByType']['Double']),
                  _buildSummaryCard('Triple Rooms Available',
                      data['availableRoomsByType']['Triple']),
                  _buildBarChart('Check-In Applications by Room Type',
                      data['checkInApplicationsByRoomType']),
                  _buildBarChart('Facility Bookings by Type',
                      data['facilityBookingsByType']),
                  _buildBarChart(
                      'Complaints by Type', data['complaintsByType']),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildBlockDetails(Map<String, dynamic> data, String blockName) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
            'Total Rooms in Block $blockName',
            data['totalRoomsByType'][blockName]!
                .values
                .reduce((a, b) => a + b)),
        _buildSummaryCard('Occupied Rooms in Block $blockName',
            data['totalOccupiedRooms'][blockName]!),
        _buildSummaryCard('Available Single Rooms in Block $blockName',
            data['availableRoomsByType'][blockName]!['Single'] ?? 0),
        _buildSummaryCard('Available Double Rooms in Block $blockName',
            data['availableRoomsByType'][blockName]!['Double'] ?? 0),
        _buildSummaryCard('Available Triple Rooms in Block $blockName',
            data['availableRoomsByType'][blockName]!['Triple'] ?? 0),
        // ... (Other relevant stats for the block)
      ],
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
