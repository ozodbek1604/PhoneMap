import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/phone.dart';
import '../services/phone_service.dart';
import '../services/auth_service.dart';

class AddPhoneScreen extends StatefulWidget {
  const AddPhoneScreen({super.key});
  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedBrand = 'Apple';
  LatLng? _selectedLocation;
  final List<XFile> _images = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _modelController.dispose(); _priceController.dispose(); _descriptionController.dispose();
    _phoneController.dispose(); _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) setState(() => _images.addAll(pickedFiles));
  }

  void _selectLocation() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Joylashuvni tanlang'),
      content: SizedBox(width: double.maxFinite, height: 400,
        child: GoogleMap(initialCameraPosition: const CameraPosition(target: LatLng(41.29, 69.24), zoom: 12),
          onTap: (latLng) { setState(() => _selectedLocation = latLng); Navigator.pop(context); })),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish'))],
    ));
  }

  Future<void> _savePhone() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iltimos, joylashuvni tanlang'))); return; }
    setState(() => _isLoading = true);
    try {
      final phone = Phone(id: const Uuid().v4(), model: _modelController.text, brand: _selectedBrand,
        price: double.parse(_priceController.text), description: _descriptionController.text, imageUrls: [],
        latitude: _selectedLocation!.latitude, longitude: _selectedLocation!.longitude, address: 'Toshkent',
        sellerId: context.read<AuthService>().userId ?? 'anonymous', sellerName: _nameController.text,
        sellerPhone: _phoneController.text, createdAt: DateTime.now());
      await context.read<PhoneService>().addPhone(phone);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E\'lon muvaffaqiyatli qo\'shildi!'))); Navigator.pop(context); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e'))); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('E\'lon qo\'shish')),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        DropdownButtonFormField<String>(value: _selectedBrand, decoration: const InputDecoration(labelText: 'Brend', border: OutlineInputBorder()),
          items: PhoneBrand.brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (v) => setState(() => _selectedBrand = v!)),
        const SizedBox(height: 16),
        TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model', hintText: 'Masalan: iPhone 14 Pro', border: OutlineInputBorder()),
          validator: (v) => v == null || v.isEmpty ? 'Modelni kiriting' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Narx', border: OutlineInputBorder()),
          validator: (v) { if (v == null || v.isEmpty) return 'Narxni kiriting'; if (double.tryParse(v) == null) return 'To\'g\'ri narx kiriting'; return null; }),
        const SizedBox(height: 16),
        TextFormField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Tavsif', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _selectLocation, icon: const Icon(Icons.location_on),
          label: Text(_selectedLocation == null ? 'Joylashuvni tanlang' : 'Joylashuv tanlangan')),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _pickImages, icon: const Icon(Icons.photo_library), label: Text('Rasm tanlash (' + _images.length.toString() + ')')),
        const SizedBox(height: 16),
        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ismingiz', border: OutlineInputBorder()),
          validator: (v) => v == null || v.isEmpty ? 'Ismingizni kiriting' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon raqamingiz', border: OutlineInputBorder()),
          validator: (v) => v == null || v.isEmpty ? 'Telefon raqamingizni kiriting' : null),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _isLoading ? null : _savePhone, style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: _isLoading ? const CircularProgressIndicator() : const Text('E\'lonni saqlash')),
      ])));
  }
}