<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Template sections/items are soft-deleted when removed from a template, so
 * inspection_items keep their template_checklist_item_id (QC-024).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('template_sections', function (Blueprint $table) {
            $table->softDeletes();
        });
        Schema::table('template_checklist_items', function (Blueprint $table) {
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::table('template_checklist_items', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
        Schema::table('template_sections', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
    }
};
