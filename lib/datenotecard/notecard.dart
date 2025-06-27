import 'package:flutter/material.dart';

class NoteCard extends StatefulWidget {
  final Map<String, dynamic> note;
  final int visualPresent;
  final int visualAbsent;
  final VoidCallback onDelete;
  final VoidCallback onIncrementPresent;
  final VoidCallback onDecrementPresent;
  final VoidCallback onIncrementAbsent;
  final VoidCallback onDecrementAbsent;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleIncluded;
  final VoidCallback? onNoteUpdated;

  const NoteCard({
    Key? key,
    required this.note,
    required this.visualPresent,
    required this.visualAbsent,
    required this.onDelete,
    required this.onIncrementPresent,
    required this.onDecrementPresent,
    required this.onIncrementAbsent,
    required this.onDecrementAbsent,
    this.onEdit,
    this.onToggleIncluded,
    this.onNoteUpdated,
  }) : super(key: key);

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late int visualPresent;
  late int visualAbsent;

  @override
  void initState() {
    super.initState();
    visualPresent = widget.visualPresent;
    visualAbsent = widget.visualAbsent;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final maxDialogWidth = 500.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth =
            screenWidth < maxDialogWidth ? screenWidth : maxDialogWidth;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 300,
              maxWidth: dialogWidth,
              minWidth: 300,
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2D55FF), Color(0xFF4A90E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                child: const Center(
                  child: Text(
                    'Delete Note',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              content: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                child: Text(
                  'Are you sure you want to delete this note? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await _controller.forward();
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        height: 110,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D55FF), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Expanded column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject name + toggle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Subject Name (ellipsized)
                      Flexible(
                        child: InkWell(
                          onTap: widget.onEdit,
                          child: Text(
                            widget.note['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // smaller spacing
                      // Toggle Chip beside name
                      GestureDetector(
                        onTap: () => widget.onToggleIncluded?.call(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: widget.note['isIncluded'] == true
                                ? Colors.green
                                : Colors.redAccent,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(1, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.note['isIncluded'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.note['isIncluded'] == true
                                    ? "Included"
                                    : "Skipped",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _attendanceCounter(
                        "Present",
                        visualPresent,
                        () {
                          setState(() {
                            widget.onIncrementPresent();
                            visualPresent++;
                          });
                        },
                        () {
                          setState(() {
                            widget.onDecrementPresent();
                            if (visualPresent > 0) visualPresent--;
                          });
                        },
                        Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Container(width: 2, height: 35, color: Colors.white54),
                      const SizedBox(width: 10),
                      _attendanceCounter(
                        "Absent",
                        visualAbsent,
                        () {
                          setState(() {
                            widget.onIncrementAbsent();
                            visualAbsent++;
                          });
                        },
                        () {
                          setState(() {
                            widget.onDecrementAbsent();
                            if (visualAbsent > 0) visualAbsent--;
                          });
                        },
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _showDeleteDialog,
                borderRadius: BorderRadius.circular(25),
                child: const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.3),
                  child:
                      Icon(Icons.delete_outline, color: Colors.black, size: 31),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attendanceCounter(
    String label,
    int count,
    VoidCallback onAdd,
    VoidCallback onRemove,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onAdd,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.remove, color: Colors.black, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
