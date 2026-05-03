<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\Api\ModuleController;



Route::post('/login', [AuthController::class, 'login']);

//nana
Route::get('/lecturer/{id}/classes', [AttendanceController::class, 'getLecturerClasses']);
Route::post('/attendance/generate', [AttendanceController::class, 'generateCode']);
Route::get('/attendance/{classSessionId}/submissions', [AttendanceController::class, 'getSubmissions']);
Route::get('/student/{id}/subjects', [AttendanceController::class, 'getRegisteredSubjects']);
Route::get('/student/{id}/modules', [AttendanceController::class, 'getRegisteredModules']);
Route::get('/student/{id}/info', [AttendanceController::class, 'getStudentInfo']);
Route::get('/student/{studentId}/attendance/{subjectId}', [AttendanceController::class, 'getStudentAttendance']);
Route::post('/attendance/{attendanceId}/status', [AttendanceController::class, 'updateAttendanceStatus']);
Route::post(
    '/attendance/submit',
    [AttendanceController::class, 'submitAttendance']
);
Route::put('/attendance/records/{attendanceId}', [AttendanceController::class, 'updateAttendanceRecord']);
Route::delete('/attendance/records/{attendanceId}', [AttendanceController::class, 'deleteAttendanceRecord']);

//meor
Route::get('/modules', [ModuleController::class, 'index']);
Route::get('/modules/{id}/schedules', [ModuleController::class, 'schedules']);
Route::post('/modules/book', [ModuleController::class, 'book']);
Route::get('/modules/my-bookings', [ModuleController::class, 'myBookings']);
Route::delete('/modules/bookings/{registrationId}/cancel', [ModuleController::class, 'cancelBooking']);
Route::get('/modules/credit-claims', [ModuleController::class, 'creditClaims']);
Route::post('/modules/credit-claims/apply', [ModuleController::class, 'applyCreditClaim']);