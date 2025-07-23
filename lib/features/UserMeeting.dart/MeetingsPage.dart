import 'package:flutter/material.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/data/models/Members.dart';
import 'package:mbari/data/services/globalFetch.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs (like phone calls)

class ChamaMembers extends StatefulWidget {
  const ChamaMembers({super.key});

  @override
  State<ChamaMembers> createState() => _ChamaMembersState();
}

class _ChamaMembersState extends State<ChamaMembers> {
  late Future<List<Members>> membersFuture;

  Future<List<Members>> fetchMembers() async {
    final response = fetchGlobal<Members>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Members.fromJson(json),
      endpoint: "members",
    );

    return response;
  }

  @override
  void initState() {
    super.initState();
    membersFuture = fetchMembers();
  }

  // Function to launch a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // You can add a SnackBar or a dialog to inform the user
      // that the call could not be launched.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      height: MediaQuery.of(context).size.height * 0.85, 
      decoration: const BoxDecoration(
       
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
       
          Expanded(
            child: FutureBuilder<List<Members>>(
              future: membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No members found.'));
                }

                final members = snapshot.data!;

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            member.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          member.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () => _makePhoneCall(member.phoneNumber),
                        ),
                        onTap: () {
                          // Optional: You can add more functionality here,
                          // e.g., showing a detailed member profile.
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}