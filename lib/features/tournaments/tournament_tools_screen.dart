
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class TournamentToolsScreen extends StatefulWidget {
  const TournamentToolsScreen({super.key});

  @override
  State<TournamentToolsScreen> createState() =>
      _TournamentToolsScreenState();
}

class _TournamentToolsScreenState
    extends State<TournamentToolsScreen> {
  static const Duration roundDuration = Duration(minutes: 30);

  Duration remaining = roundDuration;
  Timer? countdownTimer;
  bool isRunning = false;

  final Random random = Random();

  final TextEditingController notesController =
      TextEditingController();

  String coinResult = 'Flip a coin';
  String diceResult = 'Roll the dice';

  String get formattedTime {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    if (isRunning || remaining.inSeconds <= 0) return;

    setState(() {
      isRunning = true;
    });

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remaining.inSeconds <= 1) {
          timer.cancel();

          setState(() {
            remaining = Duration.zero;
            isRunning = false;
          });
        } else {
          setState(() {
            remaining -= const Duration(seconds: 1);
          });
        }
      },
    );
  }

  void pauseTimer() {
    countdownTimer?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    countdownTimer?.cancel();

    setState(() {
      remaining = roundDuration;
      isRunning = false;
    });
  }

  void flipCoin() {
    setState(() {
      coinResult = random.nextBool() ? 'Heads' : 'Tails';
    });
  }

  void rollDice() {
    setState(() {
      diceResult = '${random.nextInt(6) + 1}';
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Tools'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ROUND TIMER
            Card(
              color: const Color(0xFF26364C),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'ROUND TIMER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [],
                      ),
                    ),
                    Text(
                      remaining == Duration.zero
                          ? 'TIME EXPIRED'
                          : isRunning
                              ? 'Timer running'
                              : 'Timer paused',
                      style: TextStyle(
                        color: remaining == Duration.zero
                            ? Colors.redAccent
                            : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              isRunning || remaining == Duration.zero
                                  ? null
                                  : startTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: isRunning ? pauseTimer : null,
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          tooltip: 'Reset timer',
                          onPressed: resetTimer,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Default round length: 30 minutes',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // COIN FLIP
            Card(
              color: const Color(0xFF26364C),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 42,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Coin Flip',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      coinResult,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: flipCoin,
                      child: const Text('Flip Coin'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // DICE ROLLER
            Card(
              color: const Color(0xFF26364C),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.casino,
                      size: 42,
                      color: Colors.lightBlueAccent,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Dice Roller',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diceResult,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: rollDice,
                      child: const Text('Roll Dice'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // JUDGE NOTES
            Card(
              color: const Color(0xFF26364C),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Judge Call Notes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Record notes about a judge call or ruling.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter judge call notes...',
                        filled: true,
                        fillColor: const Color(0xFF172538),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          notesController.clear();
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear notes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
