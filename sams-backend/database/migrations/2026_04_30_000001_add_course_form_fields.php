<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
            if (!Schema::hasColumn('subjects', 'examination')) {
                $table->boolean('examination')->default(false)->after('credit_hour');
            }
            if (!Schema::hasColumn('subjects', 'exam_date')) {
                $table->date('exam_date')->nullable()->after('examination');
            }
            if (!Schema::hasColumn('subjects', 'exam_period')) {
                $table->string('exam_period', 2)->nullable()->after('exam_date');
            }
        });

        $this->addClassColumns('lecture_section');
        $this->addClassColumns('lab_section');
    }

    public function down(): void
    {
        Schema::table('subjects', function (Blueprint $table) {
            foreach (['exam_period', 'exam_date', 'examination'] as $column) {
                if (Schema::hasColumn('subjects', $column)) {
                    $table->dropColumn($column);
                }
            }
        });

        $this->dropClassColumns('lecture_section');
        $this->dropClassColumns('lab_section');
    }

    private function addClassColumns(string $tableName): void
    {
        if (!Schema::hasTable($tableName)) {
            return;
        }

        Schema::table($tableName, function (Blueprint $table) use ($tableName) {
            if (!Schema::hasColumn($tableName, 'day')) {
                $table->string('day', 20)->nullable()->after('capacity');
            }
            if (!Schema::hasColumn($tableName, 'time')) {
                $table->string('time', 20)->nullable()->after('day');
            }
            if (!Schema::hasColumn($tableName, 'instructor_name')) {
                $table->string('instructor_name')->nullable()->after('time');
            }
        });
    }

    private function dropClassColumns(string $tableName): void
    {
        if (!Schema::hasTable($tableName)) {
            return;
        }

        Schema::table($tableName, function (Blueprint $table) use ($tableName) {
            foreach (['instructor_name', 'time', 'day'] as $column) {
                if (Schema::hasColumn($tableName, $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
