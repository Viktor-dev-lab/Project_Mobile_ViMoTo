import 'package:flutter/material.dart' hide SearchBar;
import 'package:rentapp/data/models/moto.dart';
import 'package:rentapp/presentation/widgets/filter_dialog.dart';
import 'package:rentapp/presentation/widgets/moto_card.dart';
import 'package:rentapp/presentation/widgets/search_bar.dart';

class MotoListScreen extends StatefulWidget {
  const MotoListScreen({super.key});

  @override
  _MotoListScreenState createState() => _MotoListScreenState();
}

class _MotoListScreenState extends State<MotoListScreen> {
  final List<Moto> motos = [
    Moto(id: "1", model: 'Honda Vision', fuelCapacity: 5.5, distance: 10.0, pricePerHour: 8.0, status: 'available'),
    Moto(id: "2", model: 'Honda PCX 160', fuelCapacity: 8.0, distance: 15.0, pricePerHour: 10.0, status: 'available'),
    Moto(id: "3", model: 'Yamaha Aerox 155', fuelCapacity: 5.5, distance: 20.0, pricePerHour: 12.0, status: 'available'),
    Moto(id: "4", model: 'Yamaha MT-03', fuelCapacity: 14.0, distance: 25.0, pricePerHour: 15.0, status: 'available'),
    Moto(id: "5", model: 'Vespa Sprint', fuelCapacity: 7.0, distance: 12.0, pricePerHour: 10.0, status: 'available'),
    Moto(id: "6", model: 'Vespa GTS 300', fuelCapacity: 9.0, distance: 18.0, pricePerHour: 13.0, status: 'available'),
    Moto(id: "7", model: 'Suzuki Gixxer', fuelCapacity: 12.0, distance: 30.0, pricePerHour: 14.0, status: 'available'),
    Moto(id: "8", model: 'Suzuki Hayabusa', fuelCapacity: 21.0, distance: 40.0, pricePerHour: 20.0, status: 'available'),
    Moto(id: "9", model: 'Kawasaki Ninja 250', fuelCapacity: 17.0, distance: 25.0, pricePerHour: 18.0, status: 'available'),
    Moto(id: "10", model: 'Kawasaki Z900', fuelCapacity: 17.0, distance: 35.0, pricePerHour: 22.0, status: 'available'),
  ];

  List<Moto> filteredMotos = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPriceRange;

  @override
  void initState() {
    super.initState();
    filteredMotos = motos;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMotos(String query) {
    setState(() {
      filteredMotos = motos.where((moto) {
        final matchesQuery = query.isEmpty || moto.model.toLowerCase().contains(query.toLowerCase());
        final matchesPrice = _selectedPriceRange == null ||
            (_selectedPriceRange == 'under_10' && moto.pricePerHour < 10.0) ||
            (_selectedPriceRange == '10_to_15' && moto.pricePerHour >= 10.0 && moto.pricePerHour <= 15.0) ||
            (_selectedPriceRange == 'over_15' && moto.pricePerHour > 15.0);
        return matchesQuery && matchesPrice;
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterMotos('');
  }

  void _applyFilter(String? priceRange) {
    setState(() {
      _selectedPriceRange = priceRange;
      _filterMotos(_searchController.text);
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        selectedPriceRange: _selectedPriceRange,
        onApply: _applyFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade600,
        title: Row(
          children: [
            Icon(Icons.two_wheeler, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Motorbike Rental',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${filteredMotos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with search and filter
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: SearchBar(
                            controller: _searchController,
                            onChanged: _filterMotos,
                            onClear: _clearSearch,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showFilterDialog,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.tune,
                                    color: Colors.green.shade700,
                                    size: 28,
                                  ),
                                  if (_selectedPriceRange != null)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active filter chip
          if (_selectedPriceRange != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Active Filter:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    label: Text(
                      _selectedPriceRange == 'under_10'
                          ? 'Under \$10'
                          : _selectedPriceRange == '10_to_15'
                          ? '\$10 - \$15'
                          : 'Over \$15',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.green.shade50,
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                    onDeleted: () => _applyFilter(null),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                  ),
                ],
              ),
            ),

          // Results count and sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filteredMotos.length} ${filteredMotos.length == 1 ? 'Bike' : 'Bikes'} Available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Icon(Icons.grid_view, color: Colors.green.shade600, size: 20),
              ],
            ),
          ),

          // Motorbike list
          Expanded(
            child: filteredMotos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bikes found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: filteredMotos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MotoCard(moto: filteredMotos[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}