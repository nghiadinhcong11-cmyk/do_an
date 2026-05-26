import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../services/backup_service.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _dbHelper = DatabaseHelper.instance;
  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankOwnerController = TextEditingController();

  String _paperSize = '80mm';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final name = await _dbHelper.getSetting('store_name', '');
      final address = await _dbHelper.getSetting('store_address', '');
      final phone = await _dbHelper.getSetting('store_phone', '');
      final paperSize = await _dbHelper.getSetting('paper_size', '80mm');
      final bankName = await _dbHelper.getSetting('bank_name', '');
      final bankAccount = await _dbHelper.getSetting('bank_account', '');
      final bankOwner = await _dbHelper.getSetting('bank_owner', '');

      if (!mounted) return;
      setState(() {
        _storeNameController.text = name;
        _addressController.text = address;
        _phoneController.text = phone;
        _paperSize = paperSize;
        _bankNameController.text = bankName;
        _bankAccountController.text = bankAccount;
        _bankOwnerController.text = bankOwner;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _dbHelper.saveSetting('store_name', _storeNameController.text.trim());
      await _dbHelper.saveSetting('store_address', _addressController.text.trim());
      await _dbHelper.saveSetting('store_phone', _phoneController.text.trim());
      await _dbHelper.saveSetting('paper_size', _paperSize);
      await _dbHelper.saveSetting('bank_name', _bankNameController.text.trim().toUpperCase());
      await _dbHelper.saveSetting('bank_account', _bankAccountController.text.trim());
      await _dbHelper.saveSetting('bank_owner', _bankOwnerController.text.trim().toUpperCase());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Da luu cai dat thanh cong'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loi khi luu: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankOwnerController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(helperText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cai dat quan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Thong tin chung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                buildTextField(
                  label: 'Ten quan',
                  hint: 'Nhap ten quan',
                  icon: Icons.storefront,
                  controller: _storeNameController,
                ),
                const SizedBox(height: 12),
                buildTextField(
                  label: 'Dia chi',
                  hint: 'Nhap dia chi',
                  icon: Icons.location_on,
                  controller: _addressController,
                ),
                const SizedBox(height: 12),
                buildTextField(
                  label: 'So dien thoai',
                  hint: 'Nhap so dien thoai',
                  icon: Icons.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Cau hinh VietQR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 16),
                buildTextField(
                  label: 'Ma ngan hang',
                  hint: 'VD: VCB, MB, ICB',
                  icon: Icons.account_balance,
                  controller: _bankNameController,
                  helperText: 'Dung ma viet tat Napas, vi du Vietcombank la VCB',
                ),
                const SizedBox(height: 12),
                buildTextField(
                  label: 'So tai khoan',
                  hint: 'Nhap so tai khoan',
                  icon: Icons.numbers,
                  controller: _bankAccountController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                buildTextField(
                  label: 'Ten chu tai khoan',
                  hint: 'Nhap ten khong dau',
                  icon: Icons.person,
                  controller: _bankOwnerController,
                ),
                const SizedBox(height: 32),
                const Text('Du lieu va bao mat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => BackupService().createBackup(),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Sao luu du lieu (Backup)'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Quay lai', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Luu cai dat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Dang xu ly...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
