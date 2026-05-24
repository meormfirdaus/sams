import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ClaimReportPage extends StatefulWidget {
  final List<Map<String, dynamic>> claims;

  const ClaimReportPage({
    super.key,
    this.claims = const [],
  });

  @override
  State<ClaimReportPage> createState() => _ClaimReportPageState();
}

class _ClaimReportPageState extends State<ClaimReportPage> {
  final TextEditingController _emailController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  String _mode = 'Date';
  late List<Map<String, dynamic>> _filteredClaims;

  @override
  void initState() {
    super.initState();
    _filteredClaims = List<Map<String, dynamic>>.from(widget.claims);

    final dates = widget.claims
        .map((claim) => _parseClaimDate(claim))
        .whereType<DateTime>()
        .toList();

    if (dates.isEmpty) {
      final today = DateTime.now();
      _startDate = DateTime(today.year, today.month, today.day);
      _endDate = DateTime(today.year, today.month, today.day);
    } else {
      dates.sort();
      _startDate = dates.first;
      _endDate = dates.last;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DateTime? _parseClaimDate(Map<String, dynamic> claim) {
    final raw = claim['class_date'] ??
        claim['submitted_at'] ??
        claim['reviewed_at'] ??
        claim['created_at'];

    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  void _applyFilters() {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);

    setState(() {
      _filteredClaims = widget.claims.where((claim) {
        final date = _parseClaimDate(claim);
        if (date == null) return false;
        return !date.isBefore(start) && !date.isAfter(end);
      }).toList();
    });
  }

  Future<void> _pickDate({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    setState(() {
      if (start) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _printReport() async {
    final pdf = pw.Document();
    final claims = _filteredClaims;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Curriculum Credit Claims Report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('${_dateLabel(_startDate)} - ${_dateLabel(_endDate)}'),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: const ['Student', 'Matric', 'Module', 'Status'],
            data: claims.isEmpty
                ? const [
                    ['No claims', '--', '--', '--'],
                  ]
                : claims.map((claim) {
                    return [
                      claim['student_name']?.toString() ?? '--',
                      claim['matric_no']?.toString() ?? '--',
                      claim['module_code']?.toString() ?? '--',
                      claim['status']?.toString() ?? '--',
                    ];
                  }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27206F), Color(0xFF5A4DFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Claim Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _modeButton(String label, IconData icon) {
    final selected = _mode == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = label),
        child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF0C7) : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? const Color(0xFFF2B500) : Colors.black38,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: selected ? const Color(0xFFF2B500) : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime date, bool start) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _pickDate(start: start),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _dateLabel(date),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.black38),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentReport(String title, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.file_download_outlined,
                size: 18, color: Color(0xFF5A4DFF)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
                Text(
                  range,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                const Text(
                  'Generated just now',
                  style: TextStyle(fontSize: 9, color: Colors.black38),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _printReport,
            icon: const Icon(Icons.download_rounded, color: Color(0xFF5A4DFF)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2F2),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_month_outlined,
                                size: 18, color: Color(0xFFF2B500)),
                            SizedBox(width: 6),
                            Text(
                              'Generate Claim Report',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _modeButton('Date', Icons.calendar_today_outlined),
                            const SizedBox(width: 6),
                            _modeButton('Activity', Icons.flag_outlined),
                            const SizedBox(width: 6),
                            _modeButton('Student', Icons.person_outline),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _dateField('Start Date', _startDate, true),
                            const SizedBox(width: 12),
                            _dateField('End Date', _endDate, false),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: SizedBox(
                            height: 38,
                            width: 150,
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF8C24B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section(
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'firdaus@example.com',
                            hintStyle: const TextStyle(fontSize: 12),
                            prefixIcon: const Icon(Icons.email_outlined, size: 18),
                            filled: true,
                            fillColor: const Color(0xFFF7F7F8),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 42,
                          width: 210,
                          child: ElevatedButton.icon(
                            onPressed: _printReport,
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Generate & Email Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5A4DFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Claim Reports',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF27206F),
                          ),
                        ),
                        const Divider(height: 18),
                        _recentReport(
                          'Curriculum Credit Claims Report',
                          '${_dateLabel(_startDate)} - ${_dateLabel(_endDate)}',
                        ),
                        _recentReport(
                          'Curriculum Credit Claims Report',
                          '${_filteredClaims.length} claim records',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
