<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Module extends Model
{
    protected $fillable = [
        'code',
        'name',
        'location',
        'category',
        'lecturer_id',
    ];

    public function lecturer()
    {
        return $this->belongsTo(Lecturer::class);
    }
        public function schedules()
    {
        return $this->hasMany(ModuleSchedule::class);
    }

    public function registrations()
    {
        return $this->hasMany(ModuleRegistration::class);
    }
}
