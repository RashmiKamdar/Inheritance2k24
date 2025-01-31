import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_soc/routes.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class RoleAccessPage extends StatefulWidget {
  const RoleAccessPage({super.key});

  @override
  State<RoleAccessPage> createState() => _RoleAccessPageState();
}

class _RoleAccessPageState extends State<RoleAccessPage> {
  bool isloading = true;
  late Map args;
  late DocumentSnapshot build_details;
  late QueryDocumentSnapshot user_details;

  Stream fetch_all_users() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('buildingId', isEqualTo: user_details['buildingId'])
        .where('isVerified', isEqualTo: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as Map;
    user_details = args['userDetails'];
    build_details = args['buildingDetails'];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder(
            stream: fetch_all_users(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Something went Wrong ${snapshot.error}",
                      style: const TextStyle(color: Colors.white)),
                );
              }
              if (snapshot.hasData) {
                List allUsers = snapshot.data!.docs;
                return Stack(
                  children: [
                    Container(
                      child: ChooseTable(
                        allUserData: allUsers,
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                            MySocRoutes.secRoleBasedAccess,
                            arguments: {
                              'userDetails': user_details,
                              'buildingDetails': build_details
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94560),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Reload"),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class ChooseTable extends StatefulWidget {
  final allUserData;
  const ChooseTable({super.key, required this.allUserData});

  @override
  State<ChooseTable> createState() => _ChooseTableState();
}

class _ChooseTableState extends State<ChooseTable> {
  String currentChairpersonName = "None";
  String currentTreasurerName = "None";
  Set currentMember = {};
  int selectedRole = 1;

  @override
  void initState() {
    super.initState();
    var data;
    for (data in widget.allUserData) {
      if (data['designation'] == 3) {
        currentChairpersonName = '${data['firstName']} ${data['lastName']}';
      }
      if (data['designation'] == 2) {
        currentTreasurerName = '${data['firstName']} ${data['lastName']}';
      }
      if (data['designation'] == 1) {
        currentMember.add('${data['firstName']} ${data['lastName']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildCurrentRoles(),
        _buildRoleSelector(),
        Expanded(
          child: AnimationLimiter(
            child: _buildUsersList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText(
                'Role Management',
                textStyle: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
            isRepeatingAnimation: false,
          ),
          const SizedBox(height: 10),
          Container(
            height: 3,
            width: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE94560), Color(0xFF0F3460)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRoles() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          _buildRoleRow(
            'Chairperson',
            currentChairpersonName,
            const Color(0xFFE94560),
            Icons.stars,
          ),
          const Divider(color: Colors.white24),
          _buildRoleRow(
            'Treasurer',
            currentTreasurerName,
            const Color(0xFF2C698D),
            Icons.account_balance_wallet,
          ),
          const Divider(color: Colors.white24),
          _buildRoleRow(
            'Committee Members',
            '${currentMember.length} members',
            const Color(0xFF7B2CBF),
            Icons.group,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleRow(
    String role,
    String value,
    Color iconColor,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildRoleChip(
              1, 'Committee Members', Icons.group, const Color(0xFF7B2CBF)),
          _buildRoleChip(2, 'Treasurer', Icons.account_balance_wallet,
              const Color(0xFF2C698D)),
          _buildRoleChip(
              3, 'Chairperson', Icons.stars, const Color(0xFFE94560)),
        ],
      ),
    );
  }

  Widget _buildRoleChip(int role, String label, IconData icon, Color color) {
    final isSelected = selectedRole == role;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => selectedRole = selected ? role : selectedRole);
        },
        backgroundColor: color.withOpacity(0.2),
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSelected ? Colors.transparent : color,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.allUserData.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 500),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: _buildUserCard(widget.allUserData[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(QueryDocumentSnapshot user) {
    final Color cardColor = _getRoleColor(user['designation']);
    final bool isSecretary = user['designation'] == 4;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [cardColor, cardColor.withOpacity(0.7)],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          leading: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(_getRoleIcon(user['designation']), color: Colors.white),
          ),
          title: Text(
            '${user['firstName']} ${user['lastName']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                user['email'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _getRoleName(user['designation']),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          onLongPress: () => _handleRoleChange(user),
        ),
      ),
    );
  }

  Color _getRoleColor(int designation) {
    switch (designation) {
      case 4:
        return Colors.grey;
      case 3:
        return const Color(0xFFE94560);
      case 2:
        return const Color(0xFF2C698D);
      case 1:
        return const Color(0xFF7B2CBF);
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getRoleIcon(int designation) {
    switch (designation) {
      case 4:
        return Icons.admin_panel_settings;
      case 3:
        return Icons.stars;
      case 2:
        return Icons.account_balance_wallet;
      case 1:
        return Icons.group;
      default:
        return Icons.person;
    }
  }

  String _getRoleName(int designation) {
    switch (designation) {
      case 4:
        return 'Secretary';
      case 3:
        return 'Chairperson';
      case 2:
        return 'Treasurer';
      case 1:
        return 'Committee Member';
      default:
        return 'Resident';
    }
  }

  void _handleRoleChange(QueryDocumentSnapshot user) async {
    if (user['designation'] == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Secretary role cannot be modified'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (selectedRole == 1) {
        if (user['designation'] == 1) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({'designation': 0});
          currentMember.remove('${user['firstName']} ${user['lastName']}');
          setState(() {});
          throw ("User has been removed from Committee Members");
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({'designation': 1});
          currentMember.add('${user['firstName']} ${user['lastName']}');
          setState(() {});
          throw ("User has been added to the Committee Members");
        }
      }

      if (selectedRole == 2) {
        if (user['designation'] == 2) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({'designation': 0});
          currentTreasurerName = "None";
          setState(() {});
          throw ("User has been removed from Treasurer");
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({'designation': 2});
          currentTreasurerName = '${user['firstName']} ${user['lastName']}';
          setState(() {});
          throw ("User has been added as the Treasurer");
        }
      }

      if (selectedRole == 3) {
        if (user['designation'] == 3) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({'designation': 0});
          currentChairpersonName = "None";
          setState(() {});
          throw ("User has been removed as Chairperson");
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({'designation': 3});
          currentChairpersonName = '${user['firstName']} ${user['lastName']}';
          setState(() {});
          throw ("User has been added as the Chairperson");
        }
      }
    } catch (e) {
      // Show confirmation message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Role Update Success',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
