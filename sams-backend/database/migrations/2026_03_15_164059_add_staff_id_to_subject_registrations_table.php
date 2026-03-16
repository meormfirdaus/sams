<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('subject_registrations', function (Blueprint $table) {
            $table->unsignedBigInteger('staff_id')->nullable()->after('student_id');

            $table->foreign('staff_id')
                ->references('id')
                ->on('lecturers')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::table('subject_registrations', function (Blueprint $table) {
            $table->dropForeign(['staff_id']);
            $table->dropColumn('staff_id');
        });
    }
};
