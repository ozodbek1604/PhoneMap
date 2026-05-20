import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../services/phone_service.dart';
import '../widgets/phone_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final LatLng _defaultLocation = const LatLng(41.29, 69.24);
  Set<Marker> _markers = {};
  String? _selectedBrand;
  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhoneService>().loadPhones();
    });
  }

  void _updateMarkers(List<Phone> phones) {
    setState(() {
      _markers = phones.map((phone) => Marker(
        markerId: MarkerId(phone.id),
        position: LatLng(phone.latitude, phone.longitude),
        infoWindow: InfoWindow(title: phone.model, snippet: '\$' + phone.price.toStringAsFixed(0)),
        onTap: () => _showPhoneDetails(phone),
      )).toSet();
    });
  }

  void _showPhoneDetails(Phone phone) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => PhoneCard(phone: phone));
  }

  void _showFilterSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedBrand: _selectedBrand, minPrice: _minPrice, maxPrice: _maxPrice,
        onApply: (brand, min, max) {
          setState(() { _selectedBrand = brand; _minPrice = min; _maxPrice = max; });
          context.read<PhoneService>().filterPhones(brand, min, max);
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PhoneService>(
        builder: (context, phoneService, child) {
          if (phoneService.phones.isNotEmpty) _updateMarkers(phoneService.phones);
          return Stack(children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _defaultLocation, zoom: 12),
              markers: _markers, onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true, myLocationButtonEnabled: true, mapToolbarEnabled: false, zoomControlsEnabled: false,
            ),
            SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))]),
                child: TextField(decoration: const InputDecoration(hintText: 'Qidiruv...', border: InputBorder.none, icon: Icon(Icons.search)),
                  onChanged: (value) => phoneService.searchPhones(value)),
              )),
              const SizedBox(width: 8),
              Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))]),
                child: IconButton(icon: const Icon(Icons.tune), onPressed: _showFilterSheet)),
            ]))),
            if (phoneService.isLoading) const Center(child: CircularProgressIndicator()),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.pushNamed(context, '/add'), icon: const Icon(Icons.add), label: const Text('E\'lon qo\'shish')),
    );
  }
}