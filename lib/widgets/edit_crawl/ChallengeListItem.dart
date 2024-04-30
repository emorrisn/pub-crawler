import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/Challenge.dart';

class ChallengeListItem extends StatelessWidget {
  final Challenge challenge;
  final bool group;
  final bool isInChallenges;
  final Function(Challenge, bool) onUpdateChallenge;

  const ChallengeListItem({
    super.key,
    required this.challenge,
    required this.group,
    required this.isInChallenges,
    required this.onUpdateChallenge,
  });

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
                  onUpdateChallenge(challenge, newValue ?? false); // Ensure newValue is not null
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