<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Subject;
use App\Models\ClassSession;
use App\Models\SubjectRegistration;
use App\Models\Module;
use App\Models\ModuleRegistration;
use Illuminate\Support\Facades\DB;

class TestDataSeeder extends Seeder
{
    public function run(): void
    {
        // Create Lecturer
        $lecturer = User::create([
            'name' => 'Dr Ahmad',
            'email' => 'ahmad@lecturer.com',
            'password' => bcrypt('123456'),
            'role' => 'lecturer'
        ]);

        $lecturerId = DB::table('lecturers')->insertGetId([
            'user_id' => $lecturer->id,
            'staff_id' => '24680',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Create Students
        $student1 = User::create([
            'name' => 'Ahmad Zikri bin Roslan',
            'email' => 'ahmad@student.com',
            'password' => bcrypt('123456'),
            'role' => 'student',
            'matric_number' => 'CB23017'
        ]);
        $student1Id = DB::table('students')->insertGetId([
            'user_id' => $student1->id,
            'matric_no' => 'CB23017',
            'programme' => 'Software Engineering',
            'year' => 2,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $student2 = User::create([
            'name' => 'Nurul Ain binti Kamal',
            'email' => 'nurul@student.com',
            'password' => bcrypt('123456'),
            'role' => 'student',
            'matric_number' => 'CB23067'
        ]);
        $student2Id = DB::table('students')->insertGetId([
            'user_id' => $student2->id,
            'matric_no' => 'CB23067',
            'programme' => 'Software Engineering',
            'year' => 2,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $student3 = User::create([
            'name' => 'Lee Xin Wei',
            'email' => 'lee@student.com',
            'password' => bcrypt('123456'),
            'role' => 'student',
            'matric_number' => 'CB23052'
        ]);
        $student3Id = DB::table('students')->insertGetId([
            'user_id' => $student3->id,
            'matric_no' => 'CB23052',
            'programme' => 'Software Engineering',
            'year' => 2,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $student4 = User::create([
            'name' => 'Priya d/o Ramasamy',
            'email' => 'priya@student.com',
            'password' => bcrypt('123456'),
            'role' => 'student',
            'matric_number' => 'CB23093'
        ]);
        $student4Id = DB::table('students')->insertGetId([
            'user_id' => $student4->id,
            'matric_no' => 'CB23093',
            'programme' => 'Software Engineering',
            'year' => 2,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Create Subjects
        $subject1 = Subject::create([
            'code' => 'BCS3143',
            'name' => 'Software Project Management',
            'credit_hour' => 3
        ]);

        $subject2 = Subject::create([
            'code' => 'BCS3133',
            'name' => 'Software Engineering Practices',
            'credit_hour' => 3
        ]);

        // Assign both courses to the lecturer through class sessions
        ClassSession::create([
            'subject_id' => $subject1->id,
            'lecturer_id' => $lecturerId,
            'section' => 'A',
            'class_date' => '2026-03-18',
            'start_time' => '08:00:00',
            'end_time' => '10:00:00',
            'venue' => 'DK1'
        ]);

        ClassSession::create([
            'subject_id' => $subject2->id,
            'lecturer_id' => $lecturerId,
            'section' => 'A',
            'class_date' => '2026-03-20',
            'start_time' => '10:00:00',
            'end_time' => '12:00:00',
            'venue' => 'DK1'
        ]);

        // Register students to the subject
        SubjectRegistration::create([
            'student_id' => $student1Id,
            'subject_id' => $subject2->id
        ]);

        SubjectRegistration::create([
            'student_id' => $student2Id,
            'subject_id' => $subject2->id
        ]);

        SubjectRegistration::create([
            'student_id' => $student3Id,
            'subject_id' => $subject2->id
        ]);

        SubjectRegistration::create([
            'student_id' => $student4Id,
            'subject_id' => $subject2->id
        ]);

        $module1 = Module::create([
            'code' => 'HQD3062',
            'name' => 'Edit Like A Pro With Canva'
        ]);

        $module2 = Module::create([
            'code' => 'HQS3022',
            'name' => 'Kayak'
        ]);


        ModuleRegistration::create([
            'student_id' => $student1Id,
            'module_id' => $module1->id
        ]);
    }
}
