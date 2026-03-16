<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SubjectRegistration extends Model
{
    protected $table = 'subject_registrations';

    protected $fillable = [
        'student_id',
        'subject_id'
    ];

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    public function subject()
    {
        return $this->belongsTo(Subject::class, 'subject_id');
    }
}
