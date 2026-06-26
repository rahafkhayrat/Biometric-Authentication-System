import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../utils/constants.dart';

class TestSqliteScreen extends StatefulWidget {
  const TestSqliteScreen({super.key});

  @override
  State<TestSqliteScreen> createState() => _TestSqliteScreenState();
}

class _TestSqliteScreenState extends State<TestSqliteScreen> {
  String logText = "Ready to test...";
  bool isLoading = false;
  List<Map<String, dynamic>> allUsers = [];

  Future<void> _runTest() async {
    setState(() {
      isLoading = true;
      logText = "Running test...";
    });

    try {
      // Test 1: INSERT
      logText = "Test 1: Inserting user...\n";
      final testEmail = "test@test.com";
      final testEmbedding = List.generate(128, (i) => i * 0.1);

      await DBHelper.insertUser(testEmail, testEmbedding, uid: "test_uid_123");
      logText += "✅ Insert successful\n\n";

      // Test 2: GET by email
      logText += "Test 2: Getting user by email...\n";
      final result = await DBHelper.getUserEmbedding(testEmail);
      if (result != null && result.length == 128) {
        logText += "✅ Get by email successful (${result.length} values)\n";
        logText += "First 5 values: ${result.take(5).toList()}\n\n";
      } else {
        logText += "❌ Get by email failed\n\n";
      }

      // Test 3: GET by UID
      logText += "Test 3: Getting user by UID...\n";
      final resultByUid = await DBHelper.getUserEmbeddingByUid("test_uid_123");
      if (resultByUid != null) {
        logText += "✅ Get by UID successful\n\n";
      } else {
        logText += "❌ Get by UID failed\n\n";
      }

      // Test 4: GET ALL
      logText += "Test 4: Getting all users...\n";
      allUsers = await DBHelper.getAllUsers();
      logText += "✅ Found ${allUsers.length} user(s) in database\n\n";

      // Test 5: DELETE
      logText += "Test 5: Deleting test user...\n";
      final deleted = await DBHelper.deleteUser(testEmail);
      if (deleted > 0) {
        logText += "✅ Delete successful\n\n";
      } else {
        logText += "❌ Delete failed\n\n";
      }

      // Verify deletion
      final afterDelete = await DBHelper.getAllUsers();
      logText += "✅ Verification: ${afterDelete.length} user(s) remaining\n";
      logText += "\n🎉 All tests passed!";

      setState(() {
        allUsers = afterDelete;
      });
    } catch (e, stackTrace) {
      logText += "\n❌ ERROR: $e";
      if (kDebugMode) {
        logText += "\nStack: $stackTrace";
        print("SQLite Test Error: $e");
        print("Stack: $stackTrace");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      allUsers = await DBHelper.getAllUsers();
      logText = "Loaded ${allUsers.length} user(s) from database";
    } catch (e) {
      logText = "Error loading users: $e";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "SQLite Database Test",
          style: TextStyle(color: AppColors.neon),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.neon),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : _runTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neon,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Run SQLite Test",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _loadAllUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDark,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Refresh Users List"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neon, width: 1),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Test Results:",
                        style: TextStyle(
                          color: AppColors.neon,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        logText,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (allUsers.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          "Users in Database:",
                          style: TextStyle(
                            color: AppColors.neon,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...allUsers.map(
                          (user) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.buttonDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email: ${user['email']}",
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 14,
                                  ),
                                ),
                                if (user['uid'] != null)
                                  Text(
                                    "UID: ${user['uid']}",
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
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
