<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('subject_registrations', function (Blueprint $table) {
            if (!Schema::hasColumn('subject_registrations', 'section')) {
                $table->string('section', 50)->nullable()->after('subject_id');
            }

            if (!Schema::hasColumn('subject_registrations', 'tutorial_lab')) {
                $table->string('tutorial_lab', 50)->nullable()->after('section');
            }
        });
    }

    public function down(): void
    {
        Schema::table('subject_registrations', function (Blueprint $table) {
            foreach (['tutorial_lab', 'section'] as $column) {
                if (Schema::hasColumn('subject_registrations', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
