import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/Challenge.dart';
import 'package:pub_hopper_app/models/LocationChallenge.dart';

class ChallengeListItem extends StatelessWidget {
  final Challenge challenge;
  final bool group;
  final bool isInChallenges;
  final LocationChallenge locationChallenge;
  final Function(Challenge, bool) onUpdateGroupChallengesState; // Function to update group challenges state
  final Function(Challenge, bool) onUpdateIndividualChallengesState; // Function to update individual challenges state

  const ChallengeListItem({
    super.key,
    required this.challenge,
    required this.group,
    required this.isInChallenges,
    required this.locationChallenge,
    required this.onUpdateGroupChallengesState, // Receive the function to update the group challenges state
    required this.onUpdateIndividualChallengesState, // Receive the function to update the individual challenges state
  });

  void _updateGroupChallengesState(newValue) {
    if(group == true)
      {
        onUpdateGroupChallengesState(challenge, newValue!);
      } else {
      onUpdateIndividualChallengesState(challenge, newValue);
    }
  }

  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        Column(
          children: [
            ListTile(
              leading: Checkbox(
                value: isInChallenges,
                onChanged: (newValue) {
                  _updateGroupChallengesState(newValue ?? false); // Ensure newValue is not null
                },
              ),
              title: Text(
                challenge.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(challenge.description),
              isThreeLine: true,
            ),
            ListTile(
              leading: const SizedBox(
                width: 50,
              ),
              title: const Text(
                'Forfeit',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent
                ),
              ),
              subtitle:  Text(
                challenge.forfeit,
                style: const TextStyle(
                    color: Colors.redAccent
                ),),
            )
          ],
        ),
        const Divider()
      ],
    );
  }
}