<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    protected $fillable = [
        'student_id',
        'class_session_id',
        'attendance_code_id',
        'status',
        'latitude',
        'longitude',
        'location_name'
    ];

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function classSession()
    {
        return $this->belongsTo(ClassSession::class);
    }

    public function attendanceCode()
    {
        return $this->belongsTo(AttendanceCode::class);
    }
}
