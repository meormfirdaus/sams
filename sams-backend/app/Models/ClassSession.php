<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClassSession extends Model
{
    //
    protected $fillable = [
        'subject_id',
        'lecturer_id',
        'section',
        'class_date',
        'start_time',
        'end_time',
        'venue',
    ];

    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }
}
