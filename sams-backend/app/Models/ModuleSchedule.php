<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleSchedule extends Model
{
    protected $table = 'module_schedules';

    protected $fillable = [
        'module_id',
        'class_date',
        'start_time',
        'end_time',
        'venue',
        'capacity',
        'booked_count',
        'status',
        'session_type',
        'week_number',
        'lecturer_id',
    ];

    public function module()
    {
        return $this->belongsTo(Module::class);
    }

    public function lecturer()
    {
        return $this->belongsTo(Lecturer::class);
    }

    public function registrations()
    {
        return $this->hasMany(ModuleRegistration::class, 'module_schedule_id');
    }
}
