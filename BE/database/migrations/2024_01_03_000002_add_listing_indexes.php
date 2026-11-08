<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Indexes for the API's list queries (QC-029): inspections filtered by
 * inspector/status and ordered by scheduled_at, and the per-inspection
 * activity log ordered by occurred_at.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inspections', function (Blueprint $table) {
            $table->index(['inspector_id', 'status', 'scheduled_at']);
            $table->index('scheduled_at');
        });
        Schema::table('activities', function (Blueprint $table) {
            $table->index(['inspection_id', 'occurred_at']);
        });
    }

    public function down(): void
    {
        Schema::table('activities', function (Blueprint $table) {
            $table->dropIndex(['inspection_id', 'occurred_at']);
        });
        Schema::table('inspections', function (Blueprint $table) {
            $table->dropIndex(['scheduled_at']);
            $table->dropIndex(['inspector_id', 'status', 'scheduled_at']);
        });
    }
};
