<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleAttendance extends Model
{
    protected $fillable = [
        'student_id',
        'module_session_id',
        'status',
        'latitude',
        'longitude',
        'location_name',
    ];
}
