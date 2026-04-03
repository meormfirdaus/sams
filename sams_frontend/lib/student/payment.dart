import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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
  final String deadline = '21 March 2026';

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dummy file selected. Connect file picker later.'),
      ),
    );
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
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF38C6C8);
    const Color bgColor = Color(0xFFF4F4F4);
    const Color borderColor = Color(0xFFB6BDC9);
    const Color dangerColor = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 78,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: primaryColor,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                child: Form(
                  key: _formKey,
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'RM ${outstandingBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: dangerColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Deadline: $deadline',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF8E5CFF),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
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
                              const Text(
                                'Student ID',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildReadOnlyField(_studentIdController),
                              const SizedBox(height: 16),
                              const Text(
                                'Full Name',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildReadOnlyField(_fullNameController),
                              const SizedBox(height: 16),
                              const Text(
                                'Payment Amount (RM)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 1350.00',
                                  filled: true,
                                  fillColor: const Color(0xFFF2F2F2),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: borderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: primaryColor,
                                      width: 1.6,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter payment amount';
                                  }

                                  final amount = double.tryParse(value.trim());
                                  if (amount == null) {
                                    return 'Please enter valid amount';
                                  }

                                  if (amount <= 0) {
                                    return 'Amount must be more than 0';
                                  }

                                  if (amount > outstandingBalance) {
                                    return 'Amount cannot exceed outstanding balance';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildPaymentMethodOption(
                                title: 'Online Banking',
                                value: 'Online Banking',
                              ),
                              const SizedBox(height: 8),
                              _buildPaymentMethodOption(
                                title: 'Credit/Debit Card',
                                value: 'Credit/Debit Card',
                              ),
                              const SizedBox(height: 8),
                              _buildPaymentMethodOption(
                                title: 'Other',
                                value: 'Other',
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Upload Receipt',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: _chooseFile,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 22,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF8F8),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: primaryColor,
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.folder_rounded,
                                        color: Color(0xFFF4C542),
                                        size: 34,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _selectedFileName == null
                                            ? 'Choose File / Take Photo'
                                            : _selectedFileName!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedFileName == null
                                              ? primaryColor
                                              : Colors.black87,
                                          fontSize: 16,
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
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: const Icon(Icons.check_box_rounded, size: 24),
                          label: const Text(
                            'Submit Payment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFB6BDC9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFB6BDC9),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String value,
  }) {
    const Color primaryColor = Color(0xFF38C6C8);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            activeColor: primaryColor,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}