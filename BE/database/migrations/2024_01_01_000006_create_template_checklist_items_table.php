<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('template_checklist_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('section_id')->constrained('template_sections')->cascadeOnDelete();
            $table->string('label');
            $table->text('help_text')->nullable();
            $table->boolean('requires_evidence')->default(false);
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('template_checklist_items');
    }
};
