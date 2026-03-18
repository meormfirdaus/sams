<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ClassSession;
use Carbon\Carbon;

class LecturerController extends Controller
{
    /**
     * Get classes assigned to a lecturer
     */
    public function getClasses($lecturerId)
    {
        $courseClasses = ClassSession::with('subject')
            ->where('lecturer_id', $lecturerId)
            ->orderBy('class_date')
            ->orderBy('start_time')
            ->get()
            ->map(function ($class) {
                return [
                    'id' => $class->id,
                    'subject_id' => $class->subject_id,
                    'subject_code' => $class->subject->code ?? '',
                    'subject_name' => $class->subject->name ?? '',
                    'class_date' => $class->class_date,
                    'start_time' => $class->start_time,
                    'end_time' => $class->end_time,
                    'attendance_type' => 'course',
                ];
            });

        $moduleClasses = \DB::table('module_sessions')
            ->join('modules', 'module_sessions.module_id', '=', 'modules.id')
            ->where('module_sessions.lecturer_id', $lecturerId)
            ->orderBy('module_sessions.class_date')
            ->orderBy('module_sessions.start_time')
            ->select(
                'module_sessions.id',
                'module_sessions.module_id',
                'module_sessions.class_date',
                'module_sessions.start_time',
                'module_sessions.end_time',
                'modules.code as module_code',
                'modules.name as module_name'
            )
            ->get()
            ->map(function ($class) {
                return [
                    'id' => $class->id,
                    'module_id' => $class->module_id,
                    'module_code' => $class->module_code,
                    'module_name' => $class->module_name,
                    'class_date' => $class->class_date,
                    'start_time' => $class->start_time,
                    'end_time' => $class->end_time,
                    'attendance_type' => 'module',
                ];
            });

        return response()->json(
            $courseClasses->concat($moduleClasses)->values()
        );
    }
}
