<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;

class FeeController extends Controller
{
    /**
     * Resolve incoming student id safely.
     * Accept either students.id or users.id.
     */
    private function resolveStudentId($incomingStudentId): ?int
    {
        if (!$incomingStudentId) {
            return null;
        }

        $incomingStudentId = (int) $incomingStudentId;

        $directStudentId = DB::table('students')
            ->where('id', $incomingStudentId)
            ->value('id');

        if ($directStudentId) {
            return (int) $directStudentId;
        }

        $studentByUserId = DB::table('students')
            ->where('user_id', $incomingStudentId)
            ->value('id');

        if ($studentByUserId) {
            return (int) $studentByUserId;
        }

        return null;
    }

    /**
     * Student dashboard
     * Tuition Fee Management page
     */
    public function getStudentFeeStatus($studentId)
    {
        $studentId = $this->resolveStudentId($studentId);

        if (!$studentId) {
            return response()->json([
                'message' => 'Student not found'
            ], 404);
        }

        $student = DB::table('students')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->where('students.id', $studentId)
            ->select(
                'students.id',
                'students.matric_no',
                'students.programme',
                'users.name'
            )
            ->first();

        $fee = DB::table('tuition_fees')
            ->where('student_id', $studentId)
            ->orderByDesc('id')
            ->first();

        if (!$fee) {
            return response()->json([
                'message' => 'No tuition fee record found'
            ], 404);
        }

        $approvedPaid = DB::table('payments')
            ->where('student_id', $studentId)
            ->where('tuition_fee_id', $fee->id)
            ->where('status', 'Approved')
            ->sum('amount');

        $pendingPaid = DB::table('payments')
            ->where('student_id', $studentId)
            ->where('tuition_fee_id', $fee->id)
            ->where('status', 'Pending')
            ->sum('amount');

        $remaining = max(($fee->total_amount ?? 0) - $approvedPaid, 0);
        $completion = ($fee->total_amount ?? 0) > 0
            ? round(($approvedPaid / $fee->total_amount) * 100)
            : 0;

        $overallStatus = $remaining <= 0
            ? 'Paid'
            : ($approvedPaid > 0 ? 'Partial' : 'Unpaid');

        return response()->json([
            'student_name' => $student->name ?? '-',
            'matric_no' => $student->matric_no ?? '-',
            'programme' => $student->programme ?? '-',
            'semester' => ($fee->semester ?? '-') . ', ' . ($fee->session ?? '-'),
            'total_fee' => (float) ($fee->total_amount ?? 0),
            'amount_paid' => (float) $approvedPaid,
            'pending_amount' => (float) $pendingPaid,
            'remaining_balance' => (float) $remaining,
            'deadline' => !empty($fee->deadline)
                ? Carbon::parse($fee->deadline)->format('j M Y')
                : '-',
            'completion_percentage' => $completion,
            'status' => $overallStatus,
        ]);
    }

    /**
     * Student fee details page
     */
    public function getFeeDetails($studentId)
    {
        $studentId = $this->resolveStudentId($studentId);

        if (!$studentId) {
            return response()->json([
                'message' => 'Student not found'
            ], 404);
        }

        $student = DB::table('students')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->where('students.id', $studentId)
            ->select(
                'students.id',
                'students.matric_no',
                'students.programme',
                'users.name'
            )
            ->first();

        $fee = DB::table('tuition_fees')
            ->where('student_id', $studentId)
            ->orderByDesc('id')
            ->first();

        if (!$fee) {
            return response()->json([
                'message' => 'No tuition fee record found'
            ], 404);
        }

        $approvedPaid = DB::table('payments')
            ->where('student_id', $studentId)
            ->where('tuition_fee_id', $fee->id)
            ->where('status', 'Approved')
            ->sum('amount');

        $remaining = max(($fee->total_amount ?? 0) - $approvedPaid, 0);
        $completion = ($fee->total_amount ?? 0) > 0
            ? round(($approvedPaid / $fee->total_amount) * 100)
            : 0;

        $status = $remaining <= 0
            ? 'Paid'
            : ($approvedPaid > 0 ? 'Partial' : 'Unpaid');

        return response()->json([
            'student_name' => $student->name ?? '-',
            'matric_no' => $student->matric_no ?? '-',
            'programme' => $student->programme ?? '-',
            'semester' => $fee->semester ?? '-',
            'session' => $fee->session ?? '-',
            'tuition_fee' => (float) ($fee->tuition_fee ?? 0),
            'hostel_fee' => (float) ($fee->hostel_fee ?? 0),
            'total_fee' => (float) ($fee->total_amount ?? 0),
            'paid' => (float) $approvedPaid,
            'outstanding' => (float) $remaining,
            'completion_percentage' => $completion,
            'status' => $status,
            'deadline' => !empty($fee->deadline)
                ? Carbon::parse($fee->deadline)->format('j F Y')
                : '-',
        ]);
    }

    /**
     * Student submit payment
     */
    public function submitPayment(Request $request)
    {
        $request->validate([
            'student_id' => 'required|integer',
            'amount' => 'required|numeric|min:1',
            'payment_method' => 'required|in:Online Banking,Credit/Debit Card,Other',
            'receipt' => 'required|file|mimes:jpg,jpeg,png,pdf|max:4096',
        ]);

        $studentId = $this->resolveStudentId($request->student_id);

        if (!$studentId) {
            return response()->json([
                'message' => 'Student not found'
            ], 404);
        }

        $fee = DB::table('tuition_fees')
            ->where('student_id', $studentId)
            ->orderByDesc('id')
            ->first();

        if (!$fee) {
            return response()->json([
                'message' => 'No tuition fee record found'
            ], 404);
        }

        $approvedPaid = DB::table('payments')
            ->where('student_id', $studentId)
            ->where('tuition_fee_id', $fee->id)
            ->where('status', 'Approved')
            ->sum('amount');

        $remaining = max(($fee->total_amount ?? 0) - $approvedPaid, 0);

        if ($request->amount > $remaining) {
            return response()->json([
                'message' => 'Payment amount exceeds outstanding balance',
                'remaining_balance' => $remaining,
            ], 422);
        }

        $receiptPath = $request->file('receipt')->store('payment_receipts', 'public');

        $insertData = [
            'student_id' => $studentId,
            'tuition_fee_id' => $fee->id,
            'amount' => $request->amount,
            'payment_method' => $request->payment_method,
            'status' => 'Pending',
            'created_at' => now(),
            'updated_at' => now(),
        ];

        if (Schema::hasColumn('payments', 'receipt_path')) {
            $insertData['receipt_path'] = $receiptPath;
        }

        if (Schema::hasColumn('payments', 'submitted_at')) {
            $insertData['submitted_at'] = now();
        }

        DB::table('payments')->insert($insertData);

        return response()->json([
            'message' => 'Payment submitted successfully',
            'amount' => (float) $request->amount,
            'status' => 'Pending',
            'receipt_path' => $receiptPath,
        ]);
    }

    /**
     * Student payment history
     */
    public function getPaymentHistory($studentId)
    {
        $studentId = $this->resolveStudentId($studentId);

        if (!$studentId) {
            return response()->json([
                'message' => 'Student not found'
            ], 404);
        }

        $fee = DB::table('tuition_fees')
            ->where('student_id', $studentId)
            ->orderByDesc('id')
            ->first();

        if (!$fee) {
            return response()->json([
                'message' => 'No tuition fee record found'
            ], 404);
        }

        $summary = [
            'total_paid' => DB::table('payments')
                ->where('student_id', $studentId)
                ->where('tuition_fee_id', $fee->id)
                ->where('status', 'Approved')
                ->sum('amount'),
            'outstanding' => 0,
            'approved_count' => DB::table('payments')
                ->where('student_id', $studentId)
                ->where('tuition_fee_id', $fee->id)
                ->where('status', 'Approved')
                ->count(),
            'pending_count' => DB::table('payments')
                ->where('student_id', $studentId)
                ->where('tuition_fee_id', $fee->id)
                ->where('status', 'Pending')
                ->count(),
            'all_count' => DB::table('payments')
                ->where('student_id', $studentId)
                ->where('tuition_fee_id', $fee->id)
                ->count(),
        ];

        $summary['outstanding'] = max(($fee->total_amount ?? 0) - $summary['total_paid'], 0);

        $payments = DB::table('payments')
            ->where('student_id', $studentId)
            ->where('tuition_fee_id', $fee->id)
            ->orderByDesc('submitted_at')
            ->orderByDesc('id')
            ->get()
            ->map(function ($payment) {
                return [
                    'id' => $payment->id,
                    'date' => !empty($payment->submitted_at)
                        ? Carbon::parse($payment->submitted_at)->format('j M Y')
                        : (!empty($payment->created_at) ? Carbon::parse($payment->created_at)->format('j M Y') : '-'),
                    'amount' => (float) ($payment->amount ?? 0),
                    'method' => $payment->payment_method ?? '-',
                    'status' => $payment->status ?? 'Pending',
                    'receipt_path' => $payment->receipt_path ?? null,
                ];
            });

        return response()->json([
            'semester' => ($fee->semester ?? '-') . ', ' . ($fee->session ?? '-'),
            'summary' => $summary,
            'payments' => $payments,
        ]);
    }

    /**
     * Treasurer pending payment list
     */
    public function getPendingPayments(Request $request)
    {
        $query = DB::table('payments')
            ->join('students', 'payments.student_id', '=', 'students.id')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->leftJoin('tuition_fees', 'payments.tuition_fee_id', '=', 'tuition_fees.id')
            ->where('payments.status', 'Pending')
            ->select(
                'payments.id',
                'payments.amount',
                'payments.status',
                'payments.payment_method',
                'payments.submitted_at',
                'students.matric_no',
                'users.name',
                'students.programme',
                'tuition_fees.semester',
                'tuition_fees.session'
            );

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('students.matric_no', 'like', '%' . $search . '%')
                    ->orWhere('users.name', 'like', '%' . $search . '%');
            });
        }

        if ($request->filled('course')) {
            $query->where('students.programme', $request->course);
        }

        if ($request->filled('status')) {
            $query->where('payments.status', $request->status);
        }

        $records = $query
            ->orderBy('payments.submitted_at')
            ->paginate(10);

        return response()->json($records);
    }

    /**
     * Treasurer view one submitted payment
     */
    public function viewPayment($paymentId)
    {
        $payment = DB::table('payments')
            ->join('students', 'payments.student_id', '=', 'students.id')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->leftJoin('tuition_fees', 'payments.tuition_fee_id', '=', 'tuition_fees.id')
            ->where('payments.id', $paymentId)
            ->select(
                'payments.id',
                'payments.amount',
                'payments.payment_method',
                'payments.status',
                'payments.receipt_path',
                'payments.submitted_at',
                'payments.remarks',
                'students.id as student_id',
                'students.matric_no',
                'students.programme',
                'users.name',
                'tuition_fees.semester',
                'tuition_fees.session'
            )
            ->first();

        if (!$payment) {
            return response()->json([
                'message' => 'Payment not found'
            ], 404);
        }

        return response()->json([
            'payment_id' => $payment->id,
            'student_id' => $payment->student_id,
            'matric_no' => $payment->matric_no,
            'full_name' => $payment->name,
            'programme' => $payment->programme,
            'semester' => ($payment->semester ?? '-') . ', ' . ($payment->session ?? '-'),
            'amount' => (float) ($payment->amount ?? 0),
            'payment_method' => $payment->payment_method ?? '-',
            'status' => $payment->status ?? '-',
            'date_submitted' => !empty($payment->submitted_at)
                ? Carbon::parse($payment->submitted_at)->format('j M Y')
                : '-',
            'receipt_path' => $payment->receipt_path ?? null,
            'remarks' => $payment->remarks ?? null,
        ]);
    }

    /**
     * Treasurer approve payment
     */
    public function approvePayment(Request $request, $paymentId)
    {
        $payment = DB::table('payments')->where('id', $paymentId)->first();

        if (!$payment) {
            return response()->json([
                'message' => 'Payment not found'
            ], 404);
        }

        if (($payment->status ?? null) !== 'Pending') {
            return response()->json([
                'message' => 'Only pending payments can be approved'
            ], 422);
        }

        $updateData = [
            'status' => 'Approved',
            'updated_at' => now(),
        ];

        if (Schema::hasColumn('payments', 'verified_at')) {
            $updateData['verified_at'] = now();
        }

        if (Schema::hasColumn('payments', 'verified_by')) {
            $updateData['verified_by'] = optional($request->user())->id;
        }

        DB::table('payments')
            ->where('id', $paymentId)
            ->update($updateData);

        return response()->json([
            'message' => 'Payment approved successfully',
            'payment_id' => $paymentId,
            'status' => 'Approved',
        ]);
    }

    /**
     * Treasurer reject payment
     */
    public function rejectPayment(Request $request, $paymentId)
    {
        $request->validate([
            'remarks' => 'nullable|string|max:255'
        ]);

        $payment = DB::table('payments')->where('id', $paymentId)->first();

        if (!$payment) {
            return response()->json([
                'message' => 'Payment not found'
            ], 404);
        }

        if (($payment->status ?? null) !== 'Pending') {
            return response()->json([
                'message' => 'Only pending payments can be rejected'
            ], 422);
        }

        $updateData = [
            'status' => 'Rejected',
            'remarks' => $request->remarks,
            'updated_at' => now(),
        ];

        if (Schema::hasColumn('payments', 'verified_at')) {
            $updateData['verified_at'] = now();
        }

        if (Schema::hasColumn('payments', 'verified_by')) {
            $updateData['verified_by'] = optional($request->user())->id;
        }

        DB::table('payments')
            ->where('id', $paymentId)
            ->update($updateData);

        return response()->json([
            'message' => 'Payment rejected successfully',
            'payment_id' => $paymentId,
            'status' => 'Rejected',
        ]);
    }

    /**
     * Treasurer payment records
     */
    public function getPaymentRecords(Request $request)
    {
        $query = DB::table('payments')
            ->join('students', 'payments.student_id', '=', 'students.id')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->select(
                'payments.id',
                'payments.amount',
                'payments.status',
                'payments.payment_method',
                'payments.submitted_at',
                'students.matric_no',
                'users.name'
            );

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('students.matric_no', 'like', '%' . $search . '%')
                    ->orWhereDate('payments.submitted_at', $search);
            });
        }

        if ($request->filled('status')) {
            $query->where('payments.status', $request->status);
        }

        $records = $query
            ->orderByDesc('payments.submitted_at')
            ->orderByDesc('payments.id')
            ->paginate(10);

        return response()->json($records);
    }
}
