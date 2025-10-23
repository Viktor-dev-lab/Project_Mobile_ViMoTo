import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String? selectedPriceRange;
  final Function(String?) onApply;

  const FilterDialog({
    super.key,
    this.selectedPriceRange,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedPriceRange;

  @override
  void initState() {
    super.initState();
    _selectedPriceRange = widget.selectedPriceRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter by Price'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: const Text('All Prices'),
              value: null,
              groupValue: _selectedPriceRange,
              onChanged: (value) {
                setState(() {
                  _selectedPriceRange = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Under 10 \$/h'),
              value: 'under_10',
              groupValue: _selectedPriceRange,
              onChanged: (value) {
                setState(() {
                  _selectedPriceRange = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('10 - 15 \$/h'),
              value: '10_to_15',
              groupValue: _selectedPriceRange,
              onChanged: (value) {
                setState(() {
                  _selectedPriceRange = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Over 15 \$/h'),
              value: 'over_15',
              groupValue: _selectedPriceRange,
              onChanged: (value) {
                setState(() {
                  _selectedPriceRange = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_selectedPriceRange);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}