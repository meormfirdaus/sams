<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleRegistration extends Model
{
    protected $fillable = [
        'student_id',
        'module_id',
        'module_schedule_id',
    ];

    public function module()
    {
        return $this->belongsTo(Module::class);
    }

    public function schedule()
    {
        return $this->belongsTo(ModuleSchedule::class, 'module_schedule_id');
    }

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}