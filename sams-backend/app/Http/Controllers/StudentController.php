<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StudentController extends Controller
{
    /**
     * Get subjects and modules registered by a student.
     */
    public function getRegisteredSubjects($studentId)
    {
        $registrations = DB::table('subject_registrations')
            ->join('subjects', 'subject_registrations.subject_id', '=', 'subjects.id')
            ->where('subject_registrations.student_id', $studentId)
            ->select(
                'subject_registrations.id',
                'subject_registrations.student_id',
                'subject_registrations.subject_id',
                'subjects.code',
                'subjects.name'
            )
            ->orderBy('subjects.code')
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'subject_id' => $item->subject_id,
                    'code' => $item->code,
                    'name' => $item->name,
                ];
            });

        return response()->json($registrations);
    }

    public function getRegisteredModules($studentId)
    {
        $modules = DB::table('module_registrations')
            ->join('modules', 'module_registrations.module_id', '=', 'modules.id')
            ->where('module_registrations.student_id', $studentId)
            ->select(
                'module_registrations.id',
                'module_registrations.student_id',
                'module_registrations.module_id',
                'modules.code',
                'modules.name'
            )
            ->orderBy('modules.code')
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'module_id' => $item->module_id,
                    'code' => $item->code,
                    'name' => $item->name,
                ];
            });

        return response()->json($modules);
    }

    /**
     * View course details (used when student clicks View Course button in Flutter).
     */
    public function viewCourse($moduleId)
    {
        $course = DB::table('modules')
            ->where('id', $moduleId)
            ->select('id', 'code', 'name')
            ->first();

        if (!$course) {
            return response()->json([
                'message' => 'Course not found'
            ], 404);
        }

        return response()->json($course);
    }

    /**
     * Get student profile information.
     */
    public function getStudentInfo($studentId)
    {
        $student = DB::table('students')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->where('students.id', $studentId)
            ->select(
                'users.name',
                'students.matric_no as matric',
                'students.programme as program'
            )
            ->first();

        if (!$student) {
            return response()->json([
                'message' => 'Student not found'
            ], 404);
        }

        return response()->json($student);
    }
}
