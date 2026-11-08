<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('findings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('inspection_id')->constrained('inspections')->cascadeOnDelete();
            $table->foreignId('inspection_item_id')->nullable()
                ->constrained('inspection_items')->nullOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('severity'); // critical|high|medium|low
            $table->text('recommendation')->nullable();
            $table->string('status')->default('open'); // open|resolved
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('findings');
    }
};
