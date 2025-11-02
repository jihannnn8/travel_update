import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../models/tour_package.dart';
import '../services/booking_service.dart';
import '../services/data_service.dart';
import '../widgets/rating_widget.dart';

class PackageDetailPage extends StatefulWidget {
  final TourPackage package;

  const PackageDetailPage({super.key, required this.package});

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  String? _selectedPickupTime;
  String? _selectedPaymentMethod;
  bool _isLoading = false;
  double _userRating = 0.0;
  DateTime? _selectedPickupDate;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Buat tanggal penjemputan terisi otomatis dengan tanggal keberangkatan - 1 hari
    final departure = _parseDate(widget.package.departureDate);
    _selectedPickupDate = departure.subtract(const Duration(days: 1));
    _pickupDateController.text = _formatDate(_selectedPickupDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade600),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Paket',
          style: TextStyle(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar paket
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.package.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Judul paket
              Text(
                widget.package.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Lokasi
              Text(
                widget.package.destination,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Rating
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.package.rating} (${widget.package.totalRatings} ulasan)',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Berikan Rating
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Berikan Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RatingWidget(
                      initialRating: _userRating,
                      onRatingChanged: (rating) {
                        setState(() => _userRating = rating);
                      },
                    ),
                    if (_userRating > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Terima kasih atas rating Anda!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Info Harga dan Durasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    title: 'Harga',
                    value: 'Rp ${widget.package.price.toStringAsFixed(0)}',
                    color: Colors.blue.shade600,
                  ),
                  _buildInfoItem(
                    title: 'Durasi',
                    value: widget.package.duration,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Rundown
              Text(
                'Rundown Perjalanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 12),

              ...widget.package.rundown.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // =================== DETAIL PEMBAYARAN ===================
              Text(
                'Detail Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 16),

              // Nama Pemesan
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Pemesan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Lokasi Penjemputan
              TextField(
                decoration: InputDecoration(
                  labelText: 'Lokasi Penjemputan',
                  hintText: 'Masukkan alamat atau titik penjemputan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal penjemputan (disabled)
              TextField(
                controller: _pickupDateController,
                readOnly: true,
                enabled: false, // tidak bisa diklik
                decoration: InputDecoration(
                  labelText: 'Tanggal Penjemputan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Waktu penjemputan
              DropdownButtonFormField<String>(
                value: _selectedPickupTime,
                decoration: InputDecoration(
                  labelText: 'Waktu Penjemputan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.access_time_outlined),
                ),
                hint: const Text('Pilih waktu penjemputan'),
                items:
                    DataService.getPickupTimes()
                        .map(
                          (time) =>
                              DropdownMenuItem(value: time, child: Text(time)),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedPickupTime = value),
              ),
              const SizedBox(height: 20),

              // =================== METODE PEMBAYARAN ===================
              Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: [
                  _buildPaymentTile('Bank BRI', 'assets/banks/bri.png'),
                  _buildPaymentTile('Bank BCA', 'assets/banks/bca.png'),
                  _buildPaymentTile('Bank BNI', 'assets/banks/bni.png'),
                  _buildPaymentTile('SeaBank', 'assets/banks/seabank.png'),
                  _buildPaymentTile('Danamon', 'assets/banks/danamon.png'),
                ],
              ),

              if (_selectedPaymentMethod != null) ...[
                const SizedBox(height: 10),
                _buildAccountInfo(_selectedPaymentMethod!),
              ],

              const SizedBox(height: 16),

              // Tombol Pesan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookPackage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Pesan Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =================== HELPER METHOD ===================

  Widget _buildInfoItem({
    required String title,
    required String value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTile(String method, String imagePath) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Image.asset(imagePath, width: 30, height: 30),
          const SizedBox(width: 10),
          Text(method),
        ],
      ),
      value: method,
      groupValue: _selectedPaymentMethod,
      activeColor: Colors.blue.shade600,
      onChanged: (value) => setState(() => _selectedPaymentMethod = value),
    );
  }

  Widget _buildAccountInfo(String method) {
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
            icon: const Icon(Icons.copy, color: Colors.blue),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: accountNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nomor rekening disalin!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getAccountNumber(String method) {
    switch (method) {
      case 'Bank BRI':
        return 'BRI - 1234 5678 9101 112';
      case 'Bank BCA':
        return 'BCA - 0987 6543 2109 876';
      case 'Bank BNI':
        return 'BNI - 5678 9012 3456 789';
      case 'SeaBank':
        return 'SeaBank - 1012 3456 7890 123';
      case 'Danamon':
        return 'Danamon - 1122 3344 5566 778';
      default:
        return 'Nomor rekening tidak tersedia';
    }
  }

  DateTime _parseDate(String dateString) {
    final df = DateFormat('d MMMM y', 'id');
    return df.parse(dateString);
  }

  String _formatDate(DateTime date) {
    final df = DateFormat('d MMMM y', 'id');
    return df.format(date);
  }

  // =================== BOOKING HANDLER ===================

  Future<void> _bookPackage() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama pemesan wajib diisi');
      return;
    }
    if (_selectedPickupTime == null || _selectedPaymentMethod == null) {
      _showError('Silakan pilih waktu penjemputan dan metode pembayaran');
      return;
    }

    setState(() => _isLoading = true);

    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      packageId: widget.package.id,
      packageTitle: widget.package.title,
      packageImage: widget.package.imageUrl,
      price: widget.package.price,
      departureDate: widget.package.departureDate,
      customerName: _nameController.text.trim(),
      pickupDate: _formatDate(_selectedPickupDate!),
      pickupTime: _selectedPickupTime!,
      paymentMethod: _selectedPaymentMethod!,
      status: 'Menunggu Pembayaran',
      bookingDate: DateTime.now(),
      paymentInfo: 'Silakan lakukan pembayaran sesuai instruksi yang diberikan',
    );

    await BookingService.addBooking(booking);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
      _showPaymentInfo(booking);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showPaymentInfo(Booking booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Informasi Pembayaran'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paket: ${booking.packageTitle}'),
                Text('Harga: Rp ${booking.price.toStringAsFixed(0)}'),
                Text('Nama: ${booking.customerName}'),
                Text(
                  'Tanggal Jemput: ${booking.pickupDate} ${booking.pickupTime}',
                ),
                Text('Metode: ${booking.paymentMethod}'),
                Text('Status: ${booking.status}'),
                const SizedBox(height: 8),
                Text(
                  booking.paymentInfo,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
