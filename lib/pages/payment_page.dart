import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/booking.dart';

class PaymentPage extends StatelessWidget {
  final Booking booking;

  const PaymentPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // ===== Detail Booking =====
            _buildRow('Nama Pemesan', booking.customerName),
            _buildRow('Paket Wisata', booking.packageTitle),
            _buildRow('Harga', 'Rp ${booking.price.toStringAsFixed(0)}'),
            _buildRow(
              'Tanggal Jemput',
              '${booking.pickupDate} - ${booking.pickupTime}',
            ),
            _buildRow('Metode Pembayaran', booking.paymentMethod),
            const Divider(height: 30, thickness: 1),

            // ===== Rekening / VA =====
            Text(
              'Silakan lakukan pembayaran ke rekening berikut:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            _buildAccountInfo(context, booking.paymentMethod),

            const Spacer(),

            // ===== Tombol Selesai =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // ✅ teks putih
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== Widget Helper ==================

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan info rekening & tombol copy
  Widget _buildAccountInfo(BuildContext context, String method) {
    final accountNumber = _getAccountNumber(method);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              accountNumber,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF2196F3)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: accountNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nomor rekening berhasil disalin!'),
                  backgroundColor: Color(0xFF2196F3),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Nomor rekening / VA bank
  String _getAccountNumber(String method) {
    switch (method) {
      case 'Bank BRI':
        return 'BRI VA - 770001234567890';
      case 'Bank BCA':
        return 'BCA VA - 390100987654321';
      case 'Bank BNI':
        return 'BNI VA - 880812345678901';
      default:
        return 'Nomor rekening tidak tersedia';
    }
  }
}
