<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    /**
     * Basic login for all actors (student, lecturer, treasury, etc.)
     */
    public function login(Request $request)
    {
        $request->validate([
            'id_number' => 'required',
            'password' => 'required',
            'role' => 'required',
        ]);

        $loginId = strtoupper(trim($request->id_number));
        $role = strtolower(trim($request->role));

        if ($role === 'student') {
            $student = DB::table('students')
                ->join('users', 'students.user_id', '=', 'users.id')
                ->where('students.matric_no', $loginId)
                ->whereRaw('LOWER(users.role) = ?', ['student'])
                ->select(
                    'users.id as user_id',
                    'users.name',
                    'users.password',
                    'users.role',
                    'students.id as student_id'
                )
                ->first();

            if (!$student || !Hash::check($request->password, $student->password)) {
                return response()->json([
                    'message' => 'Invalid credentials'
                ], 401);
            }

            return response()->json([
                'message' => 'Login successful',
                'user_id' => $student->user_id,
                'role' => $student->role,
                'student_id' => $student->student_id,
                'lecturer_id' => null,
                'name' => $student->name,
            ]);
        }

        if ($role === 'lecturer') {
            $lecturer = DB::table('lecturers')
                ->join('users', 'lecturers.user_id', '=', 'users.id')
                ->where('lecturers.staff_id', $loginId)
                ->whereRaw('LOWER(users.role) = ?', ['lecturer'])
                ->select(
                    'users.id as user_id',
                    'users.name',
                    'users.password',
                    'users.role',
                    'lecturers.id as lecturer_id'
                )
                ->first();

            if (!$lecturer || !Hash::check($request->password, $lecturer->password)) {
                return response()->json([
                    'message' => 'Invalid credentials'
                ], 401);
            }

            return response()->json([
                'message' => 'Login successful',
                'user_id' => $lecturer->user_id,
                'role' => $lecturer->role,
                'student_id' => null,
                'lecturer_id' => $lecturer->lecturer_id,
                'name' => $lecturer->name,
            ]);
        }

        if ($role === 'treasury' || $role === 'treasurer') {
            $treasurer = DB::table('treasurers')
                ->join('users', 'treasurers.user_id', '=', 'users.id')
                ->where('treasurers.staff_id', $loginId)
                ->whereIn(DB::raw('LOWER(users.role)'), ['treasury', 'treasurer'])
                ->select(
                    'users.id as user_id',
                    'users.name',
                    'users.password',
                    'users.role',
                    'treasurers.id as treasurer_id'
                )
                ->first();

            if (!$treasurer || !Hash::check($request->password, $treasurer->password)) {
                return response()->json([
                    'message' => 'Invalid credentials'
                ], 401);
            }

            return response()->json([
                'message' => 'Login successful',
                'user_id' => $treasurer->user_id,
                'role' => $treasurer->role,
                'student_id' => null,
                'lecturer_id' => null,
                'treasurer_id' => $treasurer->treasurer_id,
                'name' => $treasurer->name,
            ]);
        }

        return response()->json([
            'message' => 'Role not supported'
        ], 422);
    }
}
