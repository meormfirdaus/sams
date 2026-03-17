<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\LecturerController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\StudentController;


Route::post('/login', [AuthController::class, 'login']);

//nana
Route::get('/lecturer/{id}/classes', [LecturerController::class, 'getClasses']);
Route::post('/attendance/generate', [AttendanceController::class, 'generateCode']);
Route::get('/attendance/{classSessionId}/submissions', [AttendanceController::class, 'getSubmissions']);
Route::get('/student/{studentId}/subjects', [StudentController::class, 'getRegisteredSubjects']);
Route::get('/student/{studentId}/modules', [StudentController::class, 'getRegisteredModules']);
Route::get('/student/{studentId}/info', [StudentController::class, 'getStudentInfo']);
Route::get('/student/{studentId}/attendance/{subjectId}', [AttendanceController::class, 'getStudentAttendance']);
Route::post('/attendance/{attendanceId}/status', [AttendanceController::class, 'updateAttendanceStatus']);
Route::post(
    '/attendance/submit',
    [AttendanceController::class, 'submitAttendance']
);
Route::put('/attendance/records/{attendanceId}', [AttendanceController::class, 'updateAttendanceRecord']);
Route::delete('/attendance/records/{attendanceId}', [AttendanceController::class, 'deleteAttendanceRecord']);
