<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('attendances', function (Blueprint $table) {

            if (!Schema::hasColumn('attendances', 'latitude')) {
                $table->decimal('latitude', 10, 7)->nullable()->after('class_session_id');
            }

            if (!Schema::hasColumn('attendances', 'longitude')) {
                $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
            }

            if (!Schema::hasColumn('attendances', 'location_name')) {
                $table->string('location_name')->nullable()->after('longitude');
            }
        });
    }

    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude', 'location_name']);
        });
    }
};
