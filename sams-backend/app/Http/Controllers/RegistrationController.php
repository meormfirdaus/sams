<?php

namespace App\Http\Controllers;

use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\Rule;

class RegistrationController extends Controller
{
    public function index(Request $request)
    {
        $studentId = $request->query('student_id');
        $registeredSubjectIds = [];

        if ($studentId && Schema::hasTable('subject_registrations')) {
            $registeredSubjectIds = DB::table('subject_registrations')
                ->where('student_id', $studentId)
                ->pluck('subject_id')
                ->map(fn ($id) => (int) $id)
                ->all();
        }

        $subjects = Subject::orderBy('code')->get();

        return $subjects->map(function (Subject $subject) use ($registeredSubjectIds) {
            return [
                'id' => $subject->id,
                'code' => $subject->code,
                'name' => $subject->name,
                'credit_hour' => $subject->credit_hour,
                'instructors' => $this->getSubjectInstructors($subject->id),
                'is_registered' => in_array((int) $subject->id, $registeredSubjectIds, true),
            ];
        });
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => ['required', 'string', 'max:255', Rule::unique('subjects', 'code')],
            'name' => ['required', 'string', 'max:255'],
            'credit_hour' => ['required', 'integer', 'min:1'],
            'examination' => ['nullable', 'boolean'],
            'exam_date' => ['nullable', 'date'],
            'exam_period' => ['nullable', 'in:AM,PM'],
            'sections' => ['nullable', 'array'],
            'sections.*.name' => ['required_with:sections', 'string', 'max:50'],
            'sections.*.day' => ['nullable', 'string', 'max:20'],
            'sections.*.time' => ['nullable', 'string', 'max:20'],
            'sections.*.location' => ['nullable', 'string', 'max:50'],
            'sections.*.capacity' => ['nullable', 'integer', 'min:0'],
            'sections.*.instructor' => ['nullable', 'string', 'max:255'],
            'tutorials' => ['nullable', 'array'],
            'tutorials.*.name' => ['required_with:tutorials', 'string', 'max:50'],
            'tutorials.*.day' => ['nullable', 'string', 'max:20'],
            'tutorials.*.time' => ['nullable', 'string', 'max:20'],
            'tutorials.*.location' => ['nullable', 'string', 'max:50'],
            'tutorials.*.capacity' => ['nullable', 'integer', 'min:0'],
            'tutorials.*.instructor' => ['nullable', 'string', 'max:255'],
        ]);

        return DB::transaction(function () use ($validated) {
            $subjectData = [
                'code' => strtoupper($validated['code']),
                'name' => $validated['name'],
                'credit_hour' => $validated['credit_hour'],
            ];

            foreach (['examination', 'exam_date', 'exam_period'] as $column) {
                if (Schema::hasColumn('subjects', $column)) {
                    $subjectData[$column] = $validated[$column] ?? null;
                }
            }

            $subject = Subject::create($subjectData);

            $this->insertClassEntries(
                'lecture_section',
                $subject->id,
                $validated['sections'] ?? []
            );
            $this->insertClassEntries(
                'lab_section',
                $subject->id,
                $validated['tutorials'] ?? []
            );

            return response()->json([
                'message' => 'Subject created successfully',
                'data' => $subject,
            ], 201);
        });
    }

    public function show($id)
    {
        $subject = Subject::findOrFail($id);
        $sections = $this->getSubjectTimetableEntries('lecture_section', $subject->id, 'L');
        $tutorials = $this->getSubjectTimetableEntries('lab_section', $subject->id, 'B');
        $legacySessions = $this->getSubjectTimetableEntries('class_sessions', $subject->id);

        return response()->json([
            'id' => $subject->id,
            'code' => $subject->code,
            'name' => $subject->name,
            'credit_hour' => $subject->credit_hour,
            'examination' => $subject->examination ?? null,
            'exam_date' => $subject->exam_date ?? null,
            'exam_period' => $subject->exam_period ?? null,
            'instructors' => $this->getSubjectInstructors($subject->id),
            'sections' => $sections,
            'tutorials' => $tutorials,
            'timetable' => array_merge($sections, $tutorials, $legacySessions),
        ]);
    }

    public function destroy($id)
    {
        $subject = Subject::findOrFail($id);
        $subject->delete();

        return response()->json(['message' => 'Subject deleted successfully']);
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'student_id' => ['required', 'integer', 'exists:students,id'],
            'subject_id' => ['required', 'integer', 'exists:subjects,id'],
            'section' => ['nullable', 'string', 'max:50'],
            'tutorial_lab' => ['nullable', 'string', 'max:50'],
        ]);

        $data = [
            'student_id' => $validated['student_id'],
            'subject_id' => $validated['subject_id'],
        ];

        foreach (['approval_status', 'registrar_id', 'section', 'tutorial_lab'] as $column) {
            if (!Schema::hasColumn('subject_registrations', $column)) {
                continue;
            }

            $data[$column] = match ($column) {
                'approval_status' => 'Pending',
                'section' => $validated['section'] ?? null,
                'tutorial_lab' => $validated['tutorial_lab'] ?? null,
                default => null,
            };
        }

        DB::table('subject_registrations')->updateOrInsert(
            [
                'student_id' => $validated['student_id'],
                'subject_id' => $validated['subject_id'],
            ],
            $data + [
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );

        return response()->json(['message' => 'Subject registered successfully']);
    }

    public function registeredSubjects($studentId)
    {
        return $this->registeredSubjectRows($studentId);
    }

    public function registeredStudentsBySubject($subjectId)
    {
        $subject = Subject::findOrFail($subjectId);

        if (!Schema::hasTable('subject_registrations')) {
            return response()->json([
                'subject' => [
                    'id' => $subject->id,
                    'code' => $subject->code,
                    'name' => $subject->name,
                ],
                'students' => [],
            ]);
        }

        $students = DB::table('subject_registrations')
            ->join('students', 'subject_registrations.student_id', '=', 'students.id')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->where('subject_registrations.subject_id', $subjectId)
            ->select(
                'students.id as student_id',
                'users.name',
                'students.matric_no',
                'students.year'
            )
            ->orderBy('users.name')
            ->get()
            ->map(function ($student) {
                return [
                    'student_id' => $student->student_id,
                    'name' => $student->name,
                    'matric_no' => $student->matric_no,
                    'year' => $student->year,
                    'advisor' => $this->getStudentAdvisor((int) $student->student_id),
                ];
            });

        return response()->json([
            'subject' => [
                'id' => $subject->id,
                'code' => $subject->code,
                'name' => $subject->name,
            ],
            'students' => $students,
        ]);
    }

    public function removeRegisteredSubject($studentId, $subjectId = null)
    {
        $query = DB::table('subject_registrations')
            ->where('student_id', $studentId);

        if ($subjectId !== null) {
            $query->where('subject_id', $subjectId);
        }

        $query->delete();

        return response()->json([
            'message' => $subjectId === null
                ? 'All subjects removed successfully'
                : 'Subject removed successfully',
        ]);
    }

    public function notifyRegistrar($studentId)
    {
        $pendingQuery = DB::table('subject_registrations')
            ->where('student_id', $studentId);

        if (Schema::hasColumn('subject_registrations', 'approval_status')) {
            $pendingQuery->where('approval_status', 'Pending');
        }

        $pendingRegistrationIds = $pendingQuery->pluck('id');

        if ($pendingRegistrationIds->isEmpty()) {
            return response()->json([
                'message' => 'No pending subject registration to notify.',
            ], 422);
        }

        if (Schema::hasTable('subject_registration_notifications')) {
            DB::table('subject_registration_notifications')->updateOrInsert(
                ['student_id' => $studentId],
                [
                    'pending_count' => $pendingRegistrationIds->count(),
                    'message' => 'Student requested subject registration approval.',
                    'notified_at' => now(),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }

        return response()->json([
            'message' => 'Faculty registrar has been notified.',
            'pending_count' => $pendingRegistrationIds->count(),
        ]);
    }

    public function approvalRequests(Request $request)
    {
        if (!Schema::hasTable('subject_registrations')) {
            return response()->json([
                'counts' => ['pending' => 0, 'approved' => 0, 'rejected' => 0],
                'students' => [],
            ]);
        }

        $query = DB::table('subject_registrations')
            ->join('students', 'subject_registrations.student_id', '=', 'students.id')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->select(
                'students.id as student_id',
                'users.name',
                'students.matric_no',
                'students.programme',
                'students.year'
            )
            ->groupBy(
                'students.id',
                'users.name',
                'students.matric_no',
                'students.programme',
                'students.year'
            )
            ->orderBy('users.name');

        $search = trim((string) $request->query('search', ''));
        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('users.name', 'like', "%$search%")
                    ->orWhere('students.matric_no', 'like', "%$search%");
            });
        }

        $students = $query->get()->map(function ($student) {
            $registrations = DB::table('subject_registrations')
                ->where('student_id', $student->student_id)
                ->get();

            return [
                'student_id' => $student->student_id,
                'name' => $student->name,
                'matric_no' => $student->matric_no,
                'programme' => $student->programme,
                'year' => $student->year,
                'advisor' => $this->getStudentAdvisor((int) $student->student_id),
                'status' => $this->approvalStatusSummary($registrations),
                'registered_count' => $registrations->count(),
            ];
        });

        return response()->json([
            'counts' => $this->approvalStatusSummary(),
            'students' => $students,
        ]);
    }

    public function studentApprovalSubjects($studentId)
    {
        $subjects = $this->registeredSubjectRows($studentId, true)->map(function ($subject) {
            return $subject + [
                'status' => $subject['approval_status'] ?? 'Pending',
            ];
        });

        return response()->json([
            'student' => $this->approvalStudentInfo($studentId),
            'subjects' => $subjects,
        ]);
    }

    public function updateRegistrationStatus(Request $request, $registrationId = null)
    {
        $validated = $request->validate([
            'status' => ['required', 'in:Pending,Approved,Rejected'],
        ]);

        if (!Schema::hasColumn('subject_registrations', 'approval_status')) {
            return response()->json([
                'message' => 'approval_status column is missing. Please run migrations.',
            ], 422);
        }

        $studentId = $request->route('studentId');
        $query = DB::table('subject_registrations');

        if ($studentId !== null) {
            $query->where('student_id', $studentId);
        } else {
            $query->where('id', $registrationId);
        }

        $query
            ->update([
                'approval_status' => $validated['status'],
                'updated_at' => now(),
            ]);

        return response()->json([
            'message' => $studentId !== null
                ? 'All subjects ' . strtolower($validated['status']) . ' successfully'
                : 'Registration status updated',
        ]);
    }

    private function insertClassEntries(string $table, int $subjectId, array $entries): void
    {
        if (!Schema::hasTable($table)) {
            return;
        }

        foreach ($entries as $entry) {
            $row = [];

            foreach (['section_name', 'section', 'name', 'lab_name', 'tutorial_name'] as $column) {
                if (Schema::hasColumn($table, $column)) {
                    $row[$column] = $entry['name'];
                    break;
                }
            }

            if (Schema::hasColumn($table, 'subject_id')) {
                $row['subject_id'] = $subjectId;
            }

            if (Schema::hasColumn($table, 'room')) {
                $row['room'] = $entry['location'] ?? null;
            }

            if (Schema::hasColumn($table, 'location')) {
                $row['location'] = $entry['location'] ?? null;
            }

            if (Schema::hasColumn($table, 'capacity')) {
                $row['capacity'] = $entry['capacity'] ?? 0;
            }

            foreach (['day', 'time'] as $column) {
                if (!Schema::hasColumn($table, $column)) {
                    continue;
                }

                $row[$column] = $entry[$column] ?? null;
            }

            foreach (['instructor', 'instructor_name'] as $column) {
                if (Schema::hasColumn($table, $column)) {
                    $row[$column] = $entry['instructor'] ?? null;
                }
            }

            DB::table($table)->insert($row);
        }
    }

    private function registeredSubjectRows($studentId, bool $includeApprovalStatus = false)
    {
        if (!Schema::hasTable('subject_registrations')) {
            return collect();
        }

        $query = DB::table('subject_registrations')
            ->join('subjects', 'subject_registrations.subject_id', '=', 'subjects.id')
            ->where('subject_registrations.student_id', $studentId)
            ->orderBy('subjects.code');

        $selects = [
            'subjects.id',
            'subjects.code',
            'subjects.name',
            'subjects.credit_hour',
            'subject_registrations.id as registration_id',
        ];

        $optionalColumns = ['section', 'tutorial_lab'];

        if ($includeApprovalStatus) {
            $optionalColumns[] = 'approval_status';
        }

        foreach ($optionalColumns as $column) {
            if (Schema::hasColumn('subject_registrations', $column)) {
                $selects[] = "subject_registrations.$column";
            }
        }

        return $query->select($selects)->get()->map(function ($subject) {
            $sections = $this->getSubjectTimetableEntries('lecture_section', $subject->id, 'L');
            $tutorials = $this->getSubjectTimetableEntries('lab_section', $subject->id, 'B');
            $legacySessions = $this->getSubjectTimetableEntries('class_sessions', $subject->id);
            $timetable = array_merge($sections, $tutorials, $legacySessions);
            $timing = $this->selectedTimetableDetails(
                $timetable,
                $subject->section ?? null,
                $subject->tutorial_lab ?? null
            );

            $row = [
                'id' => $subject->id,
                'registration_id' => $subject->registration_id,
                'code' => $subject->code,
                'name' => $subject->name,
                'credit_hour' => $subject->credit_hour,
                'section' => $timing['section'],
                'tutorial_lab' => $timing['tutorial_lab'],
                'time_summary' => $timing['time_summary'],
                'instructors' => $this->getSubjectInstructors($subject->id),
            ];

            if ($includeApprovalStatus) {
                $row['approval_status'] = $subject->approval_status ?? 'Pending';
            }

            return $row;
        });
    }

    private function approvalStatusSummary($registrations = null)
    {
        if (!Schema::hasColumn('subject_registrations', 'approval_status')) {
            return $registrations === null
                ? ['pending' => 0, 'approved' => 0, 'rejected' => 0]
                : 'Pending';
        }

        if ($registrations !== null) {
            $statuses = $registrations
                ->pluck('approval_status')
                ->map(fn ($status) => $status ?: 'Pending')
                ->unique()
                ->values();

            if ($statuses->count() === 1) {
                return (string) $statuses->first();
            }

            if ($statuses->contains('Pending')) {
                return 'Pending';
            }

            return 'Mixed';
        }

        $students = DB::table('subject_registrations')
            ->select('student_id', 'approval_status')
            ->get()
            ->groupBy('student_id')
            ->map(fn ($rows) => $this->approvalStatusSummary($rows));

        $pending  = $students->filter(fn($s) => $s === 'Pending')->count();
        $approved = $students->filter(fn($s) => $s === 'Approved')->count();
        $rejected = $students->filter(fn($s) => $s === 'Rejected')->count();

        return [
            'pending'  => $pending,
            'approved' => $approved,
            'rejected' => $rejected,
        ];
    }

    private function approvalStudentInfo($studentId): ?array
    {
        $student = DB::table('students')
            ->join('users', 'students.user_id', '=', 'users.id')
            ->where('students.id', $studentId)
            ->select(
                'students.id as student_id',
                'users.name',
                'students.matric_no',
                'students.programme',
                'students.year'
            )
            ->first();

        if (!$student) {
            return null;
        }

        return [
            'student_id' => $student->student_id,
            'name' => $student->name,
            'matric_no' => $student->matric_no,
            'programme' => $student->programme,
            'year' => $student->year,
            'advisor' => $this->getStudentAdvisor((int) $student->student_id),
        ];
    }

    private function getStudentAdvisor(int $studentId): string
    {
        if (!Schema::hasColumn('students', 'advisor')) {
            return '-';
        }

        return (string) (DB::table('students')
            ->where('id', $studentId)
            ->value('advisor') ?? '-');
    }

    private function getSubjectInstructors(int $subjectId): array
    {
        $instructors = [];

        foreach (['lecture_section', 'lab_section'] as $table) {
            if (!Schema::hasTable($table) || !Schema::hasColumn($table, 'subject_id')) {
                continue;
            }

            $instructorColumn = null;
            foreach (['instructor', 'instructor_name'] as $column) {
                if (Schema::hasColumn($table, $column)) {
                    $instructorColumn = $column;
                    break;
                }
            }

            if (!$instructorColumn) {
                continue;
            }

            $rows = DB::table($table)
                ->where('subject_id', $subjectId)
                ->whereNotNull($instructorColumn)
                ->pluck($instructorColumn)
                ->all();

            foreach ($rows as $instructor) {
                $instructor = trim((string) $instructor);
                if ($instructor !== '' && !in_array($instructor, $instructors, true)) {
                    $instructors[] = $instructor;
                }
            }
        }

        return $instructors;
    }

    private function getSubjectTimetableEntries(string $table, int $subjectId, string $mode = ''): array
    {
        if (!Schema::hasTable($table) || !Schema::hasColumn($table, 'subject_id')) {
            return [];
        }

        if ($table === 'class_sessions') {
            return DB::table($table)
                ->where('subject_id', $subjectId)
                ->get()
                ->map(function ($row) {
                    $sessionType = strtolower((string) ($row->session_type ?? ''));
                    $mode = str_contains($sessionType, 'tutorial') || str_contains($sessionType, 'lab')
                        ? 'B'
                        : 'L';
                    $startTime = (string) ($row->start_time ?? '');
                    $endTime = (string) ($row->end_time ?? '');
                    $start = $startTime === '' ? '' : substr($startTime, 0, 5);
                    $end = $endTime === '' ? '' : substr($endTime, 0, 5);

                    return [
                        'id' => $row->id ?? null,
                        'section' => (string) ($row->section ?? ''),
                        'day' => $row->class_date ? strtoupper(date('D', strtotime($row->class_date))) : '',
                        'time' => trim($start . '-' . $end, '-'),
                        'location' => (string) ($row->venue ?? ''),
                        'mode' => $mode,
                        'capacity' => '',
                        'instructor' => '',
                    ];
                })
                ->values()
                ->all();
        }

        $value = function (object $row, array $columns): string {
            foreach ($columns as $column) {
                if (property_exists($row, $column) && $row->{$column} !== null) {
                    return (string) $row->{$column};
                }
            }

            return '';
        };

        return DB::table($table)
            ->where('subject_id', $subjectId)
            ->get()
            ->map(function ($row) use ($mode, $value) {
                return [
                    'id' => $row->id ?? null,
                    'section' => $value(
                        $row,
                        ['section_name', 'section', 'name', 'lab_name', 'tutorial_name']
                    ),
                    'day' => $value($row, ['day']),
                    'time' => $value($row, ['time']),
                    'location' => $value($row, ['room', 'location']),
                    'mode' => $mode,
                    'capacity' => $value($row, ['capacity']),
                    'instructor' => $value($row, ['instructor', 'instructor_name']),
                ];
            })
            ->values()
            ->all();
    }

    private function selectedTimetableDetails(array $timetable, ?string $section, ?string $tutorialLab): array
    {
        $matches = [];
        $section = (string) ($section ?? '');
        $tutorialLab = (string) ($tutorialLab ?? '');

        foreach ($timetable as $entry) {
            $mode = $entry['mode'] ?? '';
            $entrySection = (string) ($entry['section'] ?? '');

            if ($section === '' && $mode === 'L' && $entrySection !== '') {
                $section = $entrySection;
            }

            if ($tutorialLab === '' && $mode === 'B' && $entrySection !== '') {
                $tutorialLab = $entrySection;
            }

            $isSelectedLecture = $mode === 'L' && $entrySection === $section;
            $isSelectedTutorial = $mode === 'B' && $entrySection === $tutorialLab;

            if (!$isSelectedLecture && !$isSelectedTutorial) {
                continue;
            }

            $time = trim((string) ($entry['time'] ?? ''));
            $day = trim((string) ($entry['day'] ?? ''));
            $modeLabel = $mode === 'B' ? 'B' : 'L';

            if ($time !== '' || $day !== '') {
                $matches[] = trim($time . ' (' . $day . ') ' . $modeLabel);
            }
        }

        return [
            'section' => $section,
            'tutorial_lab' => $tutorialLab,
            'time_summary' => implode(' | ', $matches),
        ];
    }

}
