<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ModuleSession extends Model
{
    protected $fillable = [
        'module_id',
        'class_date',
        'start_time',
        'end_time',
        'latitude',
        'longitude',
        'radius',
    ];
}
