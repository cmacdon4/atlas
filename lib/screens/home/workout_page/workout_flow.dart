import 'package:atlas/models/user.dart';
import 'package:flutter/material.dart';
import 'package:atlas/models/exercise.dart';
import 'package:atlas/screens/home/workout_page/timer.dart';
import 'package:atlas/models/workout.dart';
import 'package:atlas/services/database.dart';
import 'package:provider/provider.dart';
import 'package:atlas/screens/home/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class WorkoutFlow extends StatefulWidget {
  final Workout workout;

  const WorkoutFlow({super.key, required this.workout});

  @override
  State<WorkoutFlow> createState() => _WorkoutFlowState();
}

class _WorkoutFlowState extends State<WorkoutFlow> {
  late List<Exercise> exercises;
  int currentIndex = 0;
  XFile? image;

  @override
  void initState() {
    super.initState();
    exercises = widget.workout.exercises;
  }

Future<void> getImage(ImageSource source) async {
  // Ensure access to the camera.
  if (source == ImageSource.camera && !(await Permission.camera.request().isGranted)) {
    return;
  }

  // Ensure access to the photo library.
  if (source == ImageSource.gallery && !(await Permission.photos.request().isGranted)) {
    return;
  }

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
    setState(() {
      image = pickedFile;
    });
  }
}

void uploadImage() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final atlasUser = Provider.of<AtlasUser?>(context);
    final userId = atlasUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workout.workoutName,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.workout.description,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: exercises.length + 1,
              controller: PageController(viewportFraction: 0.8),
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                if (index == exercises.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 4,
                      color: Colors
                          .green[400], // Changed color to indicate completion
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the content vertically
                        children: [
                          const Text(
                            'Complete!',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          image == null ? ElevatedButton(
                            onPressed: () {
                              uploadImage();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text('Upload Photo'),
                          )
                          : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                image = null; // Remove the image
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text('Remove Photo'),
                          ),
                          const SizedBox(
                              height: 20), // Space between text and button
                          ElevatedButton(
                            onPressed: () {
                              DatabaseService()
                                  .saveCompletedWorkout(widget.workout, userId, image);
                              //navigate to the profile page
                              //Clear the navigator stack
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyHomePage(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    5), // Makes the button rectangular
                                // For slight roundness, use: borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 4,
                      color: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              // Wrap the Text widget with a Center widget
                              child: Text(
                                exercises[index]
                                    .name, // Use index instead of currentIndex
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign
                                    .center, // Center text horizontally
                              ),
                            ),
                            const SizedBox(
                                height:
                                    16), // Add some space between the exercise name and details

                            Row(
                              children: [
                                const SizedBox(width: 32),
                                const Icon(Icons.format_list_numbered,
                                    size: 20),
                                const SizedBox(
                                    width:
                                        8), // Add some space between icon and text
                                Text(
                                  ' ${exercises[index].sets} sets', // Use index to avoid issues during swiping
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const SizedBox(width: 32),
                                const Icon(Icons.repeat, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  ' ${exercises[index].reps} reps',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const SizedBox(width: 32),
                                const Icon(Icons.fitness_center, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  // Add an if statement that checks if the weight has the word "body" in it. If it does, do not display "lbs" after the weight
                                  exercises[index].weight.contains(
                                          'b') // Check if the weight contains 'b' (for body weight)
                                      ? ' ${exercises[index].weight}'
                                      : ' ${exercises[index].weight} lbs',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 16),
                            // ADD STOPWATCH HERE!
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16), // Space between the Card and TimerWidget

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TimerWidget(), // The TimerWidget
          ),
          const SizedBox(height: 16), // Space below the TimerWidget
        ],
      ),
    );
  }
}
