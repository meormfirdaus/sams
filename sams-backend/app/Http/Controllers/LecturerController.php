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
        $classes = ClassSession::with('subject')
            ->where('lecturer_id', $lecturerId)
            ->orderBy('class_date')
            ->orderBy('start_time')
            ->get()
            ->map(function ($class) {
                return [
                    'id' => $class->id,
                    'subject_code' => $class->subject->code,
                    'subject_name' => $class->subject->name,
                    'section' => $class->section,
                    'class_date' => $class->class_date,
                    'start_time' => $class->start_time,
                    'end_time' => $class->end_time,
                    'venue' => $class->venue,
                ];
            });

        return response()->json($classes);
    }
}
