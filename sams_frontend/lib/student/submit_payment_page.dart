import 'package:flutter/material.dart';
import 'fee_dashboard.dart';

class SubmitPaymentPage extends StatefulWidget {
  const SubmitPaymentPage({super.key});

  @override
  State<SubmitPaymentPage> createState() => _SubmitPaymentPageState();
}

class _SubmitPaymentPageState extends State<SubmitPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController =
      TextEditingController(text: 'CB23035');
  final TextEditingController _fullNameController = TextEditingController(
    text: 'Nur Izzah Dania binti Hipni Shahlizal',
  );
  final TextEditingController _amountController = TextEditingController();

  String _selectedPaymentMethod = 'Online Banking';
  String? _selectedFileName;
  final double outstandingBalance = 860.70;

  @override
  void dispose() {
    _studentIdController.dispose();
    _fullNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _chooseFile() {
    setState(() {
      _selectedFileName = 'receipt_payment.jpg';
    });
  }

  void _submitPayment() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload receipt first.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment submitted successfully.')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const FeeDashboardPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF40C4C4);
    const Color bgColor = Color(0xFFF4F4F4);
    const Color borderColor = Color(0xFFB6BDC9);
    const Color dangerColor = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 78,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: primaryColor,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Submit Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(37),
                              ),
                              child: const Icon(
                                Icons.savings_rounded,
                                size: 42,
                                color: Color(0xFFC7771A),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Outstanding Balance',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'RM ${outstandingBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF8E5CFF), width: 3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Details',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Student ID'),
                            const SizedBox(height: 8),
                            _buildReadOnlyField(_studentIdController),
                            const SizedBox(height: 16),
                            const Text('Full Name'),
                            const SizedBox(height: 8),
                            _buildReadOnlyField(_fullNameController),
                            const SizedBox(height: 16),
                            const Text('Payment Amount (RM)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: 'e.g. 350.00',
                                filled: true,
                                fillColor: const Color(0xFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter payment amount';
                                }
                                final amount = double.tryParse(value.trim());
                                if (amount == null) return 'Please enter valid amount';
                                if (amount <= 0) return 'Amount must be more than 0';
                                if (amount > outstandingBalance) {
                                  return 'Amount cannot exceed outstanding balance';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text('Payment Method'),
                            RadioListTile<String>(
                              value: 'Online Banking',
                              groupValue: _selectedPaymentMethod,
                              activeColor: primaryColor,
                              title: const Text('Online Banking'),
                              onChanged: (value) {
                                setState(() => _selectedPaymentMethod = value!);
                              },
                            ),
                            RadioListTile<String>(
                              value: 'Credit/Debit Card',
                              groupValue: _selectedPaymentMethod,
                              activeColor: primaryColor,
                              title: const Text('Credit/Debit Card'),
                              onChanged: (value) {
                                setState(() => _selectedPaymentMethod = value!);
                              },
                            ),
                            RadioListTile<String>(
                              value: 'Other',
                              groupValue: _selectedPaymentMethod,
                              activeColor: primaryColor,
                              title: const Text('Other'),
                              onChanged: (value) {
                                setState(() => _selectedPaymentMethod = value!);
                              },
                            ),
                            const SizedBox(height: 12),
                            const Text('Upload Receipt'),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: _chooseFile,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF8F8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: primaryColor, width: 1.5),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.folder_rounded,
                                        color: Color(0xFFF4C542), size: 34),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedFileName ?? 'Choose File / Take Photo',
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: const Icon(Icons.check_box_rounded, color: Colors.white),
                          label: const Text(
                            'Submit Payment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB6BDC9)),
        ),
      ),
    );
  }
}