import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/custom_widgets/controllers/post_card_controller.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utilities/constants.dart' as c;

class PollWidget extends StatefulWidget {
  final String postId;
  final List<String> options;
  final bool isPreview;

  const PollWidget({
    Key? key,
    required this.postId,
    required this.options,
    this.isPreview = false,
  }) : super(key: key);

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  int? _selectedOption;
  Map<int, int> _voteCounts = {};
  int _totalVotes = 0;
  bool _hasVoted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isPreview) {
      // _loadPollData();
      _isLoading = false;
      _initZeros();
    } else {
      // For preview, just show empty bars
      _isLoading = false;
      _initZeros();
    }
  }

  void _initZeros() {
    for (int i = 0; i < widget.options.length; i++) {
      _voteCounts[i] = 0;
    }
  }

  // Future<void> _loadPollData() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     // Check if user has already voted
  //     final currentUser = locator<CurrentUser>();
  //     final userVote = currentUser.getPollVote(widget.postId);

  //     if (userVote != null) {
  //       _selectedOption = userVote;
  //       _hasVoted = true;
  //     }

  //     // Get vote counts from Firestore
  //     final postDoc = await FirebaseFirestore.instance
  //         .collection('posts')
  //         .doc(widget.postId)
  //         .get();

  //     final Map<int, int> counts = {};
  //     int total = 0;

  //     if (postDoc.exists && postDoc.data()!.containsKey('pollVoteCounts')) {
  //       // If post has vote counts, use them
  //       final Map<String, dynamic> voteCounts =
  //           postDoc.data()!['pollVoteCounts'];

  //       for (int i = 0; i < widget.options.length; i++) {
  //         final count = voteCounts[i.toString()] ?? 0;
  //         counts[i] = count;
  //         total += count;
  //       }

  //       // Get total votes
  //       total = postDoc.data()!['totalPollVotes'] ?? total;
  //     } else {
  //       // If post doesn't have vote counts, initialize with zeros
  //       for (int i = 0; i < widget.options.length; i++) {
  //         counts[i] = 0;
  //       }
  //     }

  //     setState(() {
  //       _voteCounts = counts;
  //       _totalVotes = total;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //       _initZeros();
  //     });
  //   }
  // }

  Future<void> _vote(int optionIndex) async {
    if (_hasVoted || widget.isPreview) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = locator<CurrentUser>();

      // Send vote to Firestore through CurrentUser
      // final success = await currentUser.addPollVote(widget.postId, optionIndex);
      final success = true;

      if (success) {
        setState(() {
          _selectedOption = optionIndex;
          _hasVoted = true;
          _voteCounts[optionIndex] = (_voteCounts[optionIndex] ?? 0) + 1;
          _totalVotes++;
          _isLoading = false;
        });
      } else {
        // If update failed, show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register vote. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error voting: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedOption == index;
            final voteCount = _voteCounts[index] ?? 0;
            double percentage = _totalVotes > 0 ? voteCount / _totalVotes : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap:
                    _hasVoted || widget.isPreview ? null : () => _vote(index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Background container
                        Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: widget.isPreview
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Fill container for votes
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: 48,
                          width: MediaQuery.of(context).size.width *
                              0.7 *
                              percentage,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Content container (text and icons)
                        Container(
                          height: 48,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected && _hasVoted
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_hasVoted)
                                Text(
                                  '${(percentage * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          if (_hasVoted && !widget.isPreview)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '$_totalVotes votes',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
