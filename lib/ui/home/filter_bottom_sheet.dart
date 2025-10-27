
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  final Function(Map<String, dynamic> filters) onApply;

  const FilterBottomSheet({
    super.key,
    required this.onApply,
    this.initialFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String selectedCategory = 'All';
  String selectedCondition = 'All';
  String selectedSort = 'Newest';
  double selectedRadius = 50;

  final categories = ['All', 'Electronics', 'Furniture', 'Clothes', 'Books', 'Sports'];
  final conditions = ['All', 'new', 'good', 'used', 'old'];
  final sorts = ['Newest', 'Closest', 'Highest Trust'];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters ?? {};
    selectedCategory = f['category'] ?? selectedCategory;
    selectedCondition = f['condition'] ?? selectedCondition;
    selectedSort = f['sort'] ?? selectedSort;
    selectedRadius = (f['radiusKm'] ?? selectedRadius).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(height: 5, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            // Category
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((c) => ChoiceChip(
                label: Text(c),
                selected: selectedCategory == c,
                onSelected: (_) => setState(() => selectedCategory = c),
                selectedColor: kGreen.withOpacity(0.15),
              )).toList(),
            ),

            const SizedBox(height: 12),
            // Condition
            const Text('Condition', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: conditions.map((c) => ChoiceChip(
                label: Text(c),
                selected: selectedCondition == c,
                onSelected: (_) => setState(() => selectedCondition = c),
                selectedColor: kGreen.withOpacity(0.15),
              )).toList(),
            ),

            const SizedBox(height: 12),
            // Radius slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Radius (km)', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${selectedRadius.toStringAsFixed(0)} km'),
              ],
            ),
            Slider(
              value: selectedRadius,
              min: 1,
              max: 200,
              divisions: 199,
              onChanged: (v) => setState(() => selectedRadius = v),
            ),

            const SizedBox(height: 12),
            // Sort
            const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: sorts.map((s) => ChoiceChip(
                label: Text(s),
                selected: selectedSort == s,
                onSelected: (_) => setState(() => selectedSort = s),
                selectedColor: kGreen.withOpacity(0.15),
              )).toList(),
            ),

            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(double.infinity, 48)),
              onPressed: () {
                widget.onApply({
                  'category': selectedCategory,
                  'condition': selectedCondition,
                  'sort': selectedSort,
                  'radiusKm': selectedRadius.toInt(),
                });
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
