import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/phone.dart';

class PhoneDetailScreen extends StatelessWidget {
  const PhoneDetailScreen({super.key});

  Future<void> _callSeller(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _messageSeller(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as Phone;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 300, pinned: true, flexibleSpace: FlexibleSpaceBar(
          background: phone.imageUrls.isNotEmpty ? PageView.builder(itemCount: phone.imageUrls.length,
            itemBuilder: (context, index) => CachedNetworkImage(imageUrl: phone.imageUrls[index], fit: BoxFit.cover))
            : Container(color: Colors.grey[300], child: const Icon(Icons.phone_android, size: 100)))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Chip(label: Text(phone.brand)),
            Text('\$' + phone.price.toStringAsFixed(0), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green))]),
          const SizedBox(height: 16),
          Text(phone.model, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.location_on, size: 16), const SizedBox(width: 4), Text(phone.address)]),
          const SizedBox(height: 16),
          const Text('Tavsif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(phone.description),
          const SizedBox(height: 24),
          const Text('Sotuvchi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(phone.sellerName), subtitle: Text(phone.sellerPhone)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: () => _callSeller(phone.sellerPhone), icon: const Icon(Icons.call), label: const Text('Qo\'ng\'iroq'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)))),
            const SizedBox(width: 16),
            Expanded(child: OutlinedButton.icon(onPressed: () => _messageSeller(phone.sellerPhone), icon: const Icon(Icons.message), label: const Text('Xabar'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16))))]),
        ])))
      ]));
  }
}