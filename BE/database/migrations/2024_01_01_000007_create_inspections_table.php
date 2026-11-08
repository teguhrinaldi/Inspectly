<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('inspections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('template_id')->constrained('inspection_templates')->restrictOnDelete();
            $table->foreignId('customer_id')->constrained('customers')->restrictOnDelete();
            $table->foreignId('site_id')->constrained('sites')->restrictOnDelete();
            $table->foreignId('inspector_id')->constrained('users')->restrictOnDelete();
            $table->string('status')->default('draft'); // draft|scheduled|in_progress|review|completed
            $table->timestamp('scheduled_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->string('recurrence')->default('one_time'); // one_time|weekly|monthly|quarterly
            $table->timestamp('next_due_at')->nullable();
            $table->decimal('location_lat', 10, 7)->nullable();
            $table->decimal('location_lng', 10, 7)->nullable();
            $table->timestamp('location_captured_at')->nullable();
            $table->unsignedTinyInteger('pass_percentage')->nullable();
            $table->timestamps();

            $table->index(['site_id', 'status']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('inspections');
    }
};
