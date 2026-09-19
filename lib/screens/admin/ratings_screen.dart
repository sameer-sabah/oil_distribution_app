import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('appRatings');
  final Set<String> _selectedIds = <String>{};
  bool _selectAll = false;

  Future<void> _deleteRating(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التقييم'),
        content: const Text('هل أنت متأكد من حذف هذا التقييم نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _ref.child(id).remove();
      setState(() {
        _selectedIds.remove(id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف التقييم بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف التقييم: $e')),
      );
    }
  }

  Future<void> _deleteSelectedOrAll({bool deleteAll = false}) async {
    final count = deleteAll ? 'الكل' : '${_selectedIds.length} تقييمات';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(deleteAll ? 'حذف جميع التقييمات' : 'حذف التقييمات المحددة'),
        content: Text('هل أنت متأكد من حذف $count نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (deleteAll) {
        await _ref.remove();
        setState(() {
          _selectedIds.clear();
          _selectAll = false;
        });
      } else {
        final updates = <String, Object?>{};
        for (final id in _selectedIds) {
          updates[id] = null;
        }
        await _ref.update(updates);
        setState(() {
          _selectedIds.clear();
          _selectAll = false;
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحذف بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحذف: $e')),
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييمات المستخدمين'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'حذف الكل',
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
            onPressed: () => _deleteSelectedOrAll(deleteAll: true),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final value = snapshot.data?.snapshot.value;

          if (value == null) {
            return const Center(
              child: Text('لا توجد تقييمات حالياً'),
            );
          }

          final raw = Map<dynamic, dynamic>.from(value as Map);
          final ratings = raw.entries.toList();

          ratings.sort((a, b) {
            final aDate = a.value['createdAt']?.toString() ?? '';
            final bDate = b.value['createdAt']?.toString() ?? '';
            return bDate.compareTo(aDate);
          });

          return Column(
            children: [
              // Header actions: Select All & Delete Selected
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Checkbox(
                      value: _selectAll,
                      onChanged: (val) {
                        setState(() {
                          _selectAll = val ?? false;
                          if (_selectAll) {
                            _selectedIds.clear();
                            for (final r in ratings) {
                              _selectedIds.add(r.key.toString());
                            }
                          } else {
                            _selectedIds.clear();
                          }
                        });
                      },
                    ),
                    const Text('تحديد الكل', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_selectedIds.isNotEmpty)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () => _deleteSelectedOrAll(deleteAll: false),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: Text('حذف المحدد (${_selectedIds.length})'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    final entry = ratings[index];
                    final ratingId = entry.key.toString();
                    final item = Map<dynamic, dynamic>.from(entry.value as Map);
                    final int rating = int.tryParse(item['rating']?.toString() ?? '0') ?? 0;
                    final isSelected = _selectedIds.contains(ratingId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(ratingId);
                                  } else {
                                    _selectedIds.remove(ratingId);
                                    _selectAll = false;
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item['userId']?.toString() ?? 'غير معروف',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(
                                          5,
                                              (i) => Icon(
                                            i < rating ? Icons.star : Icons.star_border,
                                            size: 20,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if ((item['comment']?.toString() ?? '').isNotEmpty)
                                    Text(
                                      item['comment'].toString(),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['createdAt']?.toString() ?? '',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'حذف التقييم',
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                              onPressed: () => _deleteRating(ratingId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
