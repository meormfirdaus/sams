<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    protected $fillable = [
        'code',
        'name',
        'credit_hour',
        'examination',
        'exam_date',
        'exam_period',
    ];
}
