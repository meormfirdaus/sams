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

//izzah
use App\Http\Controllers\FeeController;

Route::prefix('tuition')->group(function () {
    // Student
    Route::get('/student/{studentId}/status', [FeeController::class, 'getStudentFeeStatus']);
    Route::get('/student/{studentId}/details', [FeeController::class, 'getFeeDetails']);
    Route::post('/student/submit-payment', [FeeController::class, 'submitPayment']);
    Route::get('/student/{studentId}/history', [FeeController::class, 'getPaymentHistory']);

    // Treasurer
    Route::get('/treasurer/pending', [FeeController::class, 'getPendingPayments']);
    Route::get('/treasurer/payment/{paymentId}', [FeeController::class, 'viewPayment']);
    Route::post('/treasurer/payment/{paymentId}/approve', [FeeController::class, 'approvePayment']);
    Route::post('/treasurer/payment/{paymentId}/reject', [FeeController::class, 'rejectPayment']);
    Route::get('/treasurer/records', [FeeController::class, 'getPaymentRecords']);
});
