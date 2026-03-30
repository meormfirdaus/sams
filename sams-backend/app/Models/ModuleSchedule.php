<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleSchedule extends Model
{
    protected $fillable = [
        'module_id',
        'class_date',
        'start_time',
        'end_time',
        'venue',
        'capacity',
        'booked_count',
        'status',
    ];

    public function module()
    {
        return $this->belongsTo(Module::class);
    }

    public function registrations()
    {
        return $this->hasMany(ModuleRegistration::class, 'module_schedule_id');
    }
}