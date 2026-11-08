<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * The "review" status was removed (QC-026): inspections waiting for review
 * were not signed off yet, so they continue as in progress.
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('inspections')->where('status', 'review')->update(['status' => 'in_progress']);
    }

    public function down(): void
    {
        // Which rows used to be "review" is not recorded; nothing to undo.
    }
};
