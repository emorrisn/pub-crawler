import 'package:pub_hopper_app/models/Challenge.dart';

class LocationChallenge {
  final String locationID;
  final List<Challenge> individualChallenges;
  final List<Challenge> groupChallenges;

  LocationChallenge({
    required this.locationID,
    required this.individualChallenges,
    required this.groupChallenges,
  });

  // Function to save the location challenge to the database
  Future<void> saveToDatabase() async {
    // Loop through individual challenges and save each one to the database
    for (final challenge in individualChallenges) {
      await challenge.saveToDatabase();
    }

    // Loop through group challenges and save each one to the database
    for (final challenge in groupChallenges) {
      await challenge.saveToDatabase();
    }
  }

}
