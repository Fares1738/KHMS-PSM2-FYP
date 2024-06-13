import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController {
  final _firestore = FirebaseFirestore.instance;

  // Cache variables
  late Map<String, dynamic> _dashboardDataCache;
  late DateTime _dashboardDataCacheTime;
  late Map<String, dynamic> _blockDataCache; // Updated to Map of Map
  late Map<String, DateTime> _blockDataCacheTime; // Updated to Map of DateTime

  // Cache duration (in seconds)
  static const int cacheDurationSeconds = 300; // 5 minutes

  DashboardController() {
    _dashboardDataCache = {};
    _dashboardDataCacheTime = DateTime.now()
        .subtract(const Duration(seconds: cacheDurationSeconds + 1));
    _blockDataCache = {}; // Initialize as empty map
    _blockDataCacheTime = {}; // Initialize as empty map
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      if (_dashboardDataCache.isNotEmpty &&
          DateTime.now().difference(_dashboardDataCacheTime).inSeconds <=
              cacheDurationSeconds) {
        return _dashboardDataCache;
      }

      final checkInApplicationsSnapshot =
          await _firestore.collection('CheckInApplications').get();
      final totalCheckInApplications = checkInApplicationsSnapshot.size;
      final pendingCheckInApplications = checkInApplicationsSnapshot.docs
          .where((doc) => doc['checkInStatus'] == 'Pending')
          .length;
      final checkInApplicationsByRoomType =
          _groupByRoomType(checkInApplicationsSnapshot.docs);

      final checkOutApplicationsSnapshot =
          await _firestore.collection('CheckOutApplications').get();
      final totalCheckOutApplications = checkOutApplicationsSnapshot.size;
      final pendingCheckOutApplications = checkOutApplicationsSnapshot.docs
          .where((doc) => doc['checkOutStatus'] == 'Pending')
          .length;

      final facilitiesSnapshot =
          await _firestore.collectionGroup('Applications').get();
      final totalFacilityBookings = facilitiesSnapshot.size;
      final pendingFacilityBookings = facilitiesSnapshot.docs
          .where((doc) => doc['facilityStatus'] == 'Pending')
          .length;
      final facilityBookingsByType =
          _groupByFacilityType(facilitiesSnapshot.docs);

      final complaintsSnapshot =
          await _firestore.collection('Complaints').get();
      final totalComplaints = complaintsSnapshot.size;
      final pendingComplaints = complaintsSnapshot.docs
          .where((doc) => doc['complaintStatus'] == 'Pending')
          .length;
      final complaintsByType = _groupByComplaintType(complaintsSnapshot.docs);

      _dashboardDataCache = {
        'totalCheckInApplications': totalCheckInApplications,
        'pendingCheckInApplications': pendingCheckInApplications,
        'checkInApplicationsByRoomType': checkInApplicationsByRoomType,
        'totalCheckOutApplications': totalCheckOutApplications,
        'pendingCheckOutApplications': pendingCheckOutApplications,
        'totalFacilityBookings': totalFacilityBookings,
        'pendingFacilityBookings': pendingFacilityBookings,
        'facilityBookingsByType': facilityBookingsByType,
        'totalComplaints': totalComplaints,
        'pendingComplaints': pendingComplaints,
        'complaintsByType': complaintsByType,
      };

      _dashboardDataCacheTime = DateTime.now();

      return _dashboardDataCache;
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return _dashboardDataCache; // Return cached data on error
    }
  }

  Future<Map<String, dynamic>> fetchBlockData(String blockName) async {
    try {
      // Check if block data is cached and valid
      if (_blockDataCache.containsKey(blockName) &&
          DateTime.now()
                  .difference(_blockDataCacheTime[blockName]!)
                  .inSeconds <=
              cacheDurationSeconds) {
        return _blockDataCache[blockName]!;
      }

      final roomsSnapshot = await _firestore
          .collection('Blocks')
          .doc(blockName)
          .collection('Rooms')
          .get();
      final Map<String, int> availableRoomsByType = {
        'Single': 0,
        'Double': 0,
        'Triple': 0
      };
      final Map<String, int> totalRoomsByType = {
        'Single': 0,
        'Double': 0,
        'Triple': 0
      };
      int occupiedRooms = 0;
      int totalRooms = 0;

      // Fetch tenant counts using batch queries
      Map<String, int> roomTenantCounts =
          await _fetchRoomTenantCounts(roomsSnapshot);

      // Iterate through rooms and update counters
      for (var roomDoc in roomsSnapshot.docs) {
        final roomType = roomDoc['roomType'] as String;
        final isAvailable = roomDoc['roomAvailability'] as bool;
        totalRoomsByType[roomType] = (totalRoomsByType[roomType] ?? 0) + 1;
        totalRooms++;

        if (!isAvailable) {
          occupiedRooms++;
        } else {
          final assignedTenants = roomTenantCounts[roomDoc.id] ?? 0;
          final capacity = _getRoomCapacity(roomType);
          if (assignedTenants < capacity) {
            availableRoomsByType[roomType] =
                (availableRoomsByType[roomType] ?? 0) + 1;
          }
        }
      }

      // Store data in block-specific cache
      _blockDataCache[blockName] = {
        'totalRooms': totalRooms,
        'occupiedRooms': occupiedRooms,
        'availableRooms': totalRooms - occupiedRooms,
        'availableRoomsByType': availableRoomsByType,
        'totalRoomsByType': totalRoomsByType,
      };

      _blockDataCacheTime[blockName] = DateTime.now();

      return _blockDataCache[blockName]!;
    } catch (e) {
      print('Error fetching block data for $blockName: $e');
      return {}; // Return empty map on error
    }
  }

  Future<Map<String, int>> _fetchRoomTenantCounts(
      QuerySnapshot roomsSnapshot) async {
    Map<String, int> roomTenantCounts = {};
    List<Future<QuerySnapshot<Map<String, dynamic>>>> tenantCountBatchFutures =
        [];
    int batchSize = 10;

    for (int i = 0; i < roomsSnapshot.docs.length; i += batchSize) {
      final batchEnd = (i + batchSize) < roomsSnapshot.docs.length
          ? (i + batchSize)
          : roomsSnapshot.docs.length;
      final batchDocs = roomsSnapshot.docs.sublist(i, batchEnd);
      tenantCountBatchFutures.add(_firestore
          .collection('CheckInApplications')
          .where('roomNo', whereIn: batchDocs.map((doc) => doc.id).toList())
          .where('checkInStatus', isEqualTo: 'Approved')
          .get());
    }

    final tenantCountSnapshots = await Future.wait(tenantCountBatchFutures);
    for (var snapshot in tenantCountSnapshots) {
      for (var doc in snapshot.docs) {
        roomTenantCounts[doc['roomNo']] = snapshot.docs.length;
      }
    }

    return roomTenantCounts;
  }

  int _getRoomCapacity(String roomType) {
    switch (roomType) {
      case 'Single':
        return 1;
      case 'Double':
        return 2;
      case 'Triple':
        return 3;
      default:
        return 0;
    }
  }

  Map<String, int> _groupByRoomType(List<QueryDocumentSnapshot> docs) {
    Map<String, int> result = {};
    for (var doc in docs) {
      final roomType = doc['roomType'] as String? ?? 'Unknown';
      result[roomType] = (result[roomType] ?? 0) + 1;
    }
    return result;
  }

  Map<String, int> _groupByFacilityType(List<QueryDocumentSnapshot> docs) {
    Map<String, int> result = {};
    for (var doc in docs) {
      final facilityType = doc.reference.parent.parent!.id;
      result[facilityType] = (result[facilityType] ?? 0) + 1;
    }
    return result;
  }

  Map<String, int> _groupByComplaintType(List<QueryDocumentSnapshot> docs) {
    Map<String, int> result = {};
    for (var doc in docs) {
      final complaintType = doc['complaintType'] as String? ?? 'Unknown';
      result[complaintType] = (result[complaintType] ?? 0) + 1;
    }
    return result;
  }
}
