<?php

namespace App\Http\Controllers\Api;

use App\Models\ModuleSchedule;
use App\Models\ModuleRegistration;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Module;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class ModuleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $studentId = $this->resolveStudentId($request->query('student_id'));

        $modules = Module::with(['lecturer.user', 'registrations.schedule'])
            ->orderBy('code')
            ->get();

        $data = $modules->map(function ($module) use ($studentId) {
            $booked = false;
            $bookedClassDate = null;

            if ($studentId) {
                $registration = $module->registrations
                    ->where('student_id', (int) $studentId)
                    ->sortByDesc('id')
                    ->first();

                if ($registration && $registration->schedule) {
                    $booked = true;

                    $date = \Carbon\Carbon::parse($registration->schedule->class_date)->format('d/m/Y');
                    $time = \Carbon\Carbon::parse($registration->schedule->start_time)->format('h:i A');

                    $bookedClassDate = $date . ', ' . $time;
                }
            }

            return [
                'id' => $module->id,
                'code' => $module->code,
                'name' => $module->name,
                'location' => $module->location,
                'lecturer' => $module->lecturer?->user?->name ?? 'N/A',
                'category' => $module->category,
                'booked' => $booked,
                'booked_class_date' => $bookedClassDate,
            ];
        });

        return response()->json([
            'status' => true,
            'data' => $data,
        ]);
    }
    public function schedules($id): JsonResponse
    {
        $module = Module::with(['lecturer.user', 'schedules'])
            ->findOrFail($id);

        $data = $module->schedules->map(function ($schedule) use ($module) {
            return [
                'id' => $schedule->id,
                'module_id' => $module->id,
                'code' => $module->code,
                'name' => $module->name,
                'date' => $schedule->class_date,
                'start_time' => $schedule->start_time,
                'end_time' => $schedule->end_time,
                'venue' => $schedule->venue,
                'lecturer' => $module->lecturer?->user?->name ?? 'N/A',
                'status' => $schedule->status,
                'capacity' => $schedule->capacity,
                'booked_count' => $schedule->booked_count,
            ];
        });

        return response()->json([
            'status' => true,
            'module' => [
                'id' => $module->id,
                'code' => $module->code,
                'name' => $module->name,
                'location' => $module->location,
                'lecturer' => $module->lecturer?->user?->name ?? 'N/A',
                'category' => $module->category,
            ],
            'data' => $data,
        ]);
    }

    public function book(Request $request): JsonResponse
    {
        $request->validate([
            'student_id' => 'required|integer',
            'module_id' => 'required|integer',
            'module_schedule_id' => 'required|integer',
        ]);

        $resolvedStudentId = $this->resolveStudentId((int) $request->student_id);

        if (!$resolvedStudentId) {
            return response()->json([
                'status' => false,
                'message' => 'Student record not found.',
            ], 404);
        }

        Log::info('Module booking request received', [
            'student_id' => $resolvedStudentId,
            'incoming_student_id' => $request->student_id,
            'module_id' => $request->module_id,
            'module_schedule_id' => $request->module_schedule_id,
        ]);

        $schedule = ModuleSchedule::findOrFail($request->module_schedule_id);

        if ($schedule->status === 'full') {
            return response()->json([
                'status' => false,
                'message' => 'This class is already full.',
            ], 400);
        }

        if ($schedule->booked_count >= $schedule->capacity) {
            $schedule->status = 'full';
            $schedule->save();

            return response()->json([
                'status' => false,
                'message' => 'This class is already full.',
            ], 400);
        }

        $alreadyBooked = ModuleRegistration::where('student_id', $resolvedStudentId)
            ->where('module_id', $request->module_id)
            ->where('module_schedule_id', $request->module_schedule_id)
            ->exists();

        Log::info('Module booking duplicate check', [
            'student_id' => $resolvedStudentId,
            'incoming_student_id' => $request->student_id,
            'module_id' => $request->module_id,
            'module_schedule_id' => $request->module_schedule_id,
            'already_booked' => $alreadyBooked,
        ]);

        if ($alreadyBooked) {
            return response()->json([
                'status' => false,
                'message' => 'Student already booked this class.',
            ], 400);
        }

        $registration = ModuleRegistration::create([
            'student_id' => $resolvedStudentId,
            'module_id' => $request->module_id,
            'module_schedule_id' => $request->module_schedule_id,
        ]);

        $schedule->booked_count = $schedule->booked_count + 1;

        if ($schedule->booked_count >= $schedule->capacity) {
            $schedule->status = 'full';
        }

        $schedule->save();

        return response()->json([
            'status' => true,
            'message' => 'Module booking successful.',
            'data' => $registration,
        ]);
    }

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

        $user = DB::table('users')
            ->where('id', $incomingStudentId)
            ->first();

        if ($user && !empty($user->matric_number)) {
            $studentByMatric = DB::table('students')
                ->where('matric_number', $user->matric_number)
                ->value('id');

            if ($studentByMatric) {
                return (int) $studentByMatric;
            }
        }

        return null;
    }
}
