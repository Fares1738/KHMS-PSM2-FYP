import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:khms/Controller/dashboardController.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final DashboardController _controller = DashboardController();
  String? _selectedBlock;
  Future<Map<String, dynamic>>? _blockDataFuture;
  Future<Map<String, dynamic>>? _generalDataFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _generalDataFuture = _controller.fetchDashboardData();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          unselectedLabelColor: const Color.fromARGB(179, 91, 91, 91),
          tabs: const [
            Tab(text: 'Check-Ins'),
            Tab(text: 'Check-Outs'),
            Tab(text: 'Facilities'),
            Tab(text: 'Complaints'),
            Tab(text: 'Blocks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCheckInsTab(),
          _buildCheckOutsTab(),
          _buildFacilitiesTab(),
          _buildComplaintsTab(),
          _buildBlocksTab(),
        ],
      ),
    );
  }

  Widget _buildCheckInsTab() {
    return _buildTabContent(
      future: _generalDataFuture,
      builder: (data) => Column(
        children: [
          _buildSummaryCard(
            'Total Check-In Applications',
            data['totalCheckInApplications'],
            Icons.person_add,
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
          ),
          _buildSummaryCard(
            'Pending Check-In Applications',
            data['pendingCheckInApplications'],
            Icons.pending_actions,
            const Color(0xFFFFA000),
            const Color(0xFFFFCA28),
          ),
          _buildBarChart(
            'Check-In Applications by Room Type',
            data['checkInApplicationsByRoomType'],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutsTab() {
    return _buildTabContent(
      future: _generalDataFuture,
      builder: (data) => Column(
        children: [
          _buildSummaryCard(
            'Total Check-Out Applications',
            data['totalCheckOutApplications'],
            Icons.exit_to_app,
            const Color(0xFF7B1FA2),
            const Color(0xFF9C27B0),
          ),
          _buildSummaryCard(
            'Pending Check-Out Applications',
            data['pendingCheckOutApplications'],
            Icons.pending_actions,
            const Color(0xFFC62828),
            const Color(0xFFE53935),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesTab() {
    return _buildTabContent(
      future: _generalDataFuture,
      builder: (data) => Column(
        children: [
          _buildSummaryCard(
            'Total Facility Bookings',
            data['totalFacilityBookings'],
            Icons.event,
            const Color(0xFF0097A7),
            const Color(0xFF00BCD4),
          ),
          _buildSummaryCard(
            'Pending Facility Bookings',
            data['pendingFacilityBookings'],
            Icons.pending_actions,
            const Color(0xFFFF5722),
            const Color(0xFFFF7043),
          ),
          _buildFacilityChart(
            'Facility Bookings by Type',
            data['facilityBookingsByType'],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return _buildTabContent(
      future: _generalDataFuture,
      builder: (data) => Column(
        children: [
          _buildSummaryCard(
            'Total Complaints',
            data['totalComplaints'],
            Icons.report_problem,
            const Color(0xFFD32F2F),
            const Color(0xFFE57373),
          ),
          _buildSummaryCard(
            'Pending Complaints',
            data['pendingComplaints'],
            Icons.pending_actions,
            const Color(0xFF795548),
            const Color(0xFFA1887F),
          ),
          _buildBarChart(
            'Complaints by Type',
            data['complaintsByType'],
          ),
        ],
      ),
    );
  }

  Widget _buildBlocksTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showBlockSelectionDialog,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(_selectedBlock ?? 'Select Block'),
            ),
            const SizedBox(height: 20),
            if (_selectedBlock != null)
              FutureBuilder(
                future: _blockDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
    );
  }

  Widget _buildTabContent({
    required Future<Map<String, dynamic>>? future,
    required Widget Function(Map<String, dynamic> data) builder,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return builder(snapshot.data!);
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int value, IconData icon,
      Color startColor, Color endColor) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.toString(),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockDetails(Map<String, dynamic> data, String blockName) {
    return Column(
      children: [
        _buildSummaryCard('Total Rooms', data['totalRooms'], Icons.hotel,
            const Color(0xFF3949AB), const Color(0xFF5C6BC0)),
        _buildSummaryCard('Occupied Rooms', data['occupiedRooms'], Icons.person,
            const Color(0xFF00897B), const Color(0xFF26A69A)),
        _buildSummaryCard(
            'Available Single Rooms',
            data['availableRoomsByType']['Single'] ?? 0,
            Icons.single_bed,
            const Color(0xFF7B1FA2),
            const Color(0xFF9C27B0)),
        _buildSummaryCard(
            'Available Double Rooms',
            data['availableRoomsByType']['Double'] ?? 0,
            Icons.hotel,
            const Color(0xFFC62828),
            const Color(0xFFE53935)),
        _buildSummaryCard(
            'Available Triple Rooms',
            data['availableRoomsByType']['Triple'] ?? 0,
            Icons.people,
            const Color(0xFF689F38),
            const Color(0xFF7CB342)),
      ],
    );
  }

  Widget _buildBarChart(String title, Map<String, int> data) {
    final List<BarChartGroupData> barGroups = data.entries.map((entry) {
      return BarChartGroupData(
        x: data.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue.shade300,
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data.keys.toList()[value.toInt()],
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityChart(String title, Map<String, int> data) {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
    ];

    int total = data.values.reduce((sum, value) => sum + value);

    data.entries.toList().asMap().forEach((index, entry) {
      final double percentage = entry.value / total * 100;
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Handle touch events if needed
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(data, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> data, List<Color> colors) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: data.entries.toList().asMap().entries.map((entry) {
        int index = entry.key;
        MapEntry<String, int> dataEntry = entry.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors[index % colors.length].withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${dataEntry.key}: ${dataEntry.value}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
