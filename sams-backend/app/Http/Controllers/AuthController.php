<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    /**
     * Basic login for all actors (student, lecturer, treasury, faculty_registrar, pusat_adab)
     */
    public function login(Request $request)
    {
        $request->validate([
            'id_number' => 'required',
            'password'  => 'required',
            'role'      => 'required',
        ]);

        $loginId = strtoupper(trim($request->id_number));
        $role    = strtolower(trim($request->role));

        // ─── STUDENT ────────────────────────────────────────────────────────────
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
                return response()->json(['message' => 'Invalid credentials'], 401);
            }

            return response()->json([
                'message'      => 'Login successful',
                'user_id'      => $student->user_id,
                'role'         => $student->role,
                'student_id'   => $student->student_id,
                'lecturer_id'  => null,
                'treasurer_id' => null,
                'registrar_id' => null,
                'name'         => $student->name,
            ]);
        }

        // ─── LECTURER ───────────────────────────────────────────────────────────
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
                return response()->json(['message' => 'Invalid credentials'], 401);
            }

            return response()->json([
                'message'      => 'Login successful',
                'user_id'      => $lecturer->user_id,
                'role'         => $lecturer->role,
                'student_id'   => null,
                'lecturer_id'  => $lecturer->lecturer_id,
                'treasurer_id' => null,
                'registrar_id' => null,
                'name'         => $lecturer->name,
            ]);
        }

        // ─── TREASURY / TREASURER ───────────────────────────────────────────────
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
                return response()->json(['message' => 'Invalid credentials'], 401);
            }

            return response()->json([
                'message'      => 'Login successful',
                'user_id'      => $treasurer->user_id,
                'role'         => $treasurer->role,
                'student_id'   => null,
                'lecturer_id'  => null,
                'treasurer_id' => $treasurer->treasurer_id,
                'registrar_id' => null,
                'name'         => $treasurer->name,
            ]);
        }

        // ─── FACULTY REGISTRAR ──────────────────────────────────────────────────
        if ($role === 'faculty_registrar') {
            $registrar = DB::table('faculty_registrar')
                ->join('users', 'faculty_registrar.user_id', '=', 'users.id')
                ->where('faculty_registrar.staff_id', $loginId)
                ->whereRaw('LOWER(users.role) = ?', ['faculty_registrar'])
                ->select(
                    'users.id as user_id',
                    'users.name',
                    'users.password',
                    'users.role',
                    'faculty_registrar.id as registrar_id',
                    'faculty_registrar.faculty'
                )
                ->first();

            if (!$registrar || !Hash::check($request->password, $registrar->password)) {
                return response()->json(['message' => 'Invalid credentials'], 401);
            }

            return response()->json([
                'message'      => 'Login successful',
                'user_id'      => $registrar->user_id,
                'role'         => $registrar->role,
                'student_id'   => null,
                'lecturer_id'  => null,
                'treasurer_id' => null,
                'registrar_id' => $registrar->registrar_id,
                'faculty'      => $registrar->faculty,
                'name'         => $registrar->name,
            ]);
        }

        // ─── PUSAT ADAB ─────────────────────────────────────────────────────────
        if ($role === 'pusat_adab') {
            $pusatAdab = DB::table('users')
                ->whereRaw('LOWER(role) = ?', ['pusat_adab'])
                ->where(function ($q) use ($loginId) {
                    $q->where('matric_number', $loginId)
                      ->orWhere('email', strtolower($loginId));
                })
                ->select(
                    'id as user_id',
                    'name',
                    'password',
                    'role'
                )
                ->first();

            if (!$pusatAdab || !Hash::check($request->password, $pusatAdab->password)) {
                return response()->json(['message' => 'Invalid credentials'], 401);
            }

            return response()->json([
                'message'      => 'Login successful',
                'user_id'      => $pusatAdab->user_id,
                'role'         => $pusatAdab->role,
                'student_id'   => null,
                'lecturer_id'  => null,
                'treasurer_id' => null,
                'registrar_id' => null,
                'name'         => $pusatAdab->name,
            ]);
        }

        // ─── UNSUPPORTED ROLE ───────────────────────────────────────────────────
        return response()->json(['message' => 'Role not supported'], 422);
    }
}
