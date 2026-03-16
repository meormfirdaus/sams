<?php

namespace App\Http\Controllers;

use App\Models\AttendanceCode;
use App\Models\Attendance;
use App\Models\ClassSession;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Schema;

class AttendanceController extends Controller
{
    /**
     * Generate and save attendance code for a class session.
     */
    public function generateCode(Request $request)
    {
        $request->validate([
            'class_session_id' => 'required|exists:class_sessions,id',
        ]);

        $classSession = ClassSession::findOrFail($request->class_session_id);

        $now = Carbon::now();
        $classStart = Carbon::parse($classSession->class_date . ' ' . $classSession->start_time);
        $classEnd = Carbon::parse($classSession->class_date . ' ' . $classSession->end_time);

        if ($now->lt($classStart) || $now->gt($classEnd)) {
            return response()->json([
                'message' => 'Attendance code can only be generated during class time.',
                'class_date' => $classSession->class_date,
                'start_time' => $classSession->start_time,
                'end_time' => $classSession->end_time,
            ], 422);
        }

        $code = Str::upper(Str::random(6));

        $attendanceCode = AttendanceCode::create([
            'class_session_id' => $request->class_session_id,
            'code' => $code,
            'expires_at' => $classEnd,
        ]);

        return response()->json([
            'message' => 'Attendance code generated successfully',
            'attendance_code' => $attendanceCode->code,
            'class_session_id' => $attendanceCode->class_session_id,
            'expires_at' => $attendanceCode->expires_at,
        ]);
    }

    /**
     * Get attendance submissions for a class session.
     */
    public function getSubmissions($classSessionId)
    {
        $submissions = DB::table('attendances')
            ->leftJoin('students', 'attendances.student_id', '=', 'students.id')
            ->leftJoin('users', 'students.user_id', '=', 'users.id')
            ->where('attendances.class_session_id', $classSessionId)
            ->select(
                'attendances.id',
                'attendances.status',
                'attendances.location_name',
                'attendances.created_at as submitted_at',
                DB::raw("COALESCE(users.name, 'Unknown Student') as student_name"),
                DB::raw("COALESCE(students.matric_no, '-') as matric_no")
            )
            ->orderBy('attendances.created_at')
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->student_name,
                    'matric' => $item->matric_no,
                    'time' => $item->submitted_at
                        ? Carbon::parse($item->submitted_at)->format('g:i a')
                        : '-',
                    'status' => $item->status ?? 'Pending',
                    'location_name' => $item->location_name ?? '-',
                ];
            });

        return response()->json($submissions);
    }

    /**
     * Get attendance dashboard data for a student and subject.
     */
    public function getStudentAttendance($studentId, $subjectId)
    {
        $student = DB::table('students')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->where('students.id', $studentId)
            ->select(
                'users.name as student_name',
                'students.matric_no as matric_number',
                'students.programme'
            )
            ->first();

        $sessions = DB::table('class_sessions')
            ->where('subject_id', $subjectId)
            ->pluck('id');

        $records = DB::table('attendances')
            ->where('student_id', $studentId)
            ->whereIn('class_session_id', $sessions)
            ->get();

        $present = $records->where('status', 'Present')->count();
        $late = $records->where('status', 'Late')->count();
        $absent = $records->where('status', 'Absent')->count();

        $totalClasses = $sessions->count();
        $attended = $present + $late;

        $attendanceRate = $totalClasses > 0
            ? round(($attended / $totalClasses) * 100) . '%'
            : '0%';

        $recentRecords = DB::table('attendances')
            ->join('class_sessions', 'attendances.class_session_id', '=', 'class_sessions.id')
            ->where('attendances.student_id', $studentId)
            ->where('class_sessions.subject_id', $subjectId)
            ->select(
                'class_sessions.id',
                'class_sessions.class_date',
                'class_sessions.start_time',
                'attendances.status',
                'attendances.created_at'
            )
            ->orderByDesc('class_sessions.class_date')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    'session' => 'Lecture W' . $item->id,
                    'date' => Carbon::parse($item->class_date)->format('j F Y'),
                    'time' => $item->created_at
                        ? Carbon::parse($item->created_at)->format('g:i a')
                        : '-',
                    'status' => $item->status,
                ];
            });

        $currentSession = DB::table('class_sessions')
            ->where('subject_id', $subjectId)
            ->orderByDesc('class_date')
            ->orderByDesc('start_time')
            ->first();

        $activeCode = null;
        if ($currentSession) {
            $activeCode = AttendanceCode::where('class_session_id', $currentSession->id)
                ->where('expires_at', '>', Carbon::now())
                ->latest()
                ->first();
        }

        return response()->json([
            'student_name' => $student->student_name ?? '-',
            'matric_number' => $student->matric_number ?? '-',
            'programme' => $student->programme ?? '-',
            'present_count' => $present,
            'late_count' => $late,
            'absent_count' => $absent,
            'classes_attend' => $attended,
            'total_classes' => $totalClasses,
            'attendance_rate' => $attendanceRate,
            'current_session_title' => $currentSession
                ? 'Lecture Session - ' . Carbon::parse($currentSession->class_date)->format('l, j F Y')
                : '-',
            'current_session_date' => $currentSession
                ? Carbon::parse($currentSession->class_date)->format('j F Y')
                : '-',
            'current_session_time' => $currentSession
                ? Carbon::parse($currentSession->start_time)->format('g:i a') . ' - ' . Carbon::parse($currentSession->end_time)->format('g:i a')
                : '-',
            'active_code' => $activeCode->code ?? '-',
            'recent_records' => $recentRecords,
        ]);
    }

    /**
     * Student submits attendance code.
     */
    public function submitAttendance(Request $request)
    {
        $request->validate([
            'student_id' => 'required|exists:students,id',
            'code' => 'required',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $attendanceCode = AttendanceCode::where('code', Str::upper($request->code))
            ->where('expires_at', '>', Carbon::now())
            ->first();

        if (!$attendanceCode) {
            return response()->json([
                'message' => 'Invalid or expired attendance code',
            ], 422);
        }

        $alreadySubmitted = DB::table('attendances')
            ->where('student_id', $request->student_id)
            ->where('class_session_id', $attendanceCode->class_session_id)
            ->exists();

        if ($alreadySubmitted) {
            return response()->json([
                'message' => 'Attendance has already been submitted for this class',
            ], 422);
        }

        $session = ClassSession::find($attendanceCode->class_session_id);
        $now = Carbon::now();
        $classStart = Carbon::parse($session->class_date . ' ' . $session->start_time);
        $lateThreshold = (clone $classStart)->addMinutes(15);

        $status = $now->gt($lateThreshold) ? 'Late' : 'Present';

        $latitude = $request->latitude;
        $longitude = $request->longitude;
        $locationName = null;

        if (!is_null($latitude) && !is_null($longitude)) {
            $locationName = $this->getLocationName($latitude, $longitude);
        }

        $attendanceData = [
            'student_id' => $request->student_id,
            'class_session_id' => $attendanceCode->class_session_id,
            'status' => $status,
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ];

        if (Schema::hasColumn('attendances', 'latitude')) {
            $attendanceData['latitude'] = $latitude;
        }

        if (Schema::hasColumn('attendances', 'longitude')) {
            $attendanceData['longitude'] = $longitude;
        }

        if (Schema::hasColumn('attendances', 'location_name')) {
            $attendanceData['location_name'] = $locationName;
        }

        DB::table('attendances')->insert($attendanceData);

        return response()->json([
            'message' => 'Attendance submitted successfully',
            'status' => $status,
            'location_name' => $locationName ?? 'Location verified successfully',
        ]);
    }


    private function getLocationName($lat, $lon)
    {
        $response = Http::withHeaders([
            'User-Agent' => 'SAMS Attendance System'
        ])->get('https://nominatim.openstreetmap.org/reverse', [
            'lat' => $lat,
            'lon' => $lon,
            'format' => 'json'
        ]);

        if (!$response->ok()) {
            return 'Location unavailable';
        }

        $data = $response->json();

        if (!isset($data['display_name'])) {
            return 'Unknown location';
        }

        $location = explode(',', $data['display_name'])[0];

        return $location;
    }
}
