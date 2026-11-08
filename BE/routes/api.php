<?php

use App\Http\Controllers\Api\ActivityController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\EvidenceController;
use App\Http\Controllers\Api\FindingController;
use App\Http\Controllers\Api\InspectionController;
use App\Http\Controllers\Api\InspectionItemController;
use App\Http\Controllers\Api\InspectionTemplateController;
use App\Http\Controllers\Api\InspectorController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\SignatureController;
use App\Http\Controllers\Api\SiteController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Implements the contract in docs/architecture.md §5. Auth is Laravel
| Sanctum bearer tokens; admin-only endpoints (template/customer/inspector
| create-update-delete) are gated with the `admin` middleware alias.
|
*/

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Inspections
    Route::get('/inspections', [InspectionController::class, 'index']);
    Route::get('/inspections/{inspection}', [InspectionController::class, 'show']);
    Route::post('/inspections', [InspectionController::class, 'store']);
    Route::put('/inspections/{inspection}', [InspectionController::class, 'update']);
    Route::post('/inspections/{inspection}/start', [InspectionController::class, 'start']);
    Route::post('/inspections/{inspection}/complete', [InspectionController::class, 'complete']);
    Route::put('/inspections/{inspection}/items/{item}', [InspectionItemController::class, 'update']);

    // Inspection templates (admin-only writes)
    Route::get('/inspection-templates', [InspectionTemplateController::class, 'index']);
    Route::get('/inspection-templates/{inspectionTemplate}', [InspectionTemplateController::class, 'show']);
    Route::middleware('admin')->group(function () {
        Route::post('/inspection-templates', [InspectionTemplateController::class, 'store']);
        Route::put('/inspection-templates/{inspectionTemplate}', [InspectionTemplateController::class, 'update']);
        Route::delete('/inspection-templates/{inspectionTemplate}', [InspectionTemplateController::class, 'destroy']);
    });

    // Customers (admin-only writes)
    Route::get('/customers', [CustomerController::class, 'index']);
    Route::get('/customers/{customer}', [CustomerController::class, 'show']);
    Route::middleware('admin')->group(function () {
        Route::post('/customers', [CustomerController::class, 'store']);
        Route::put('/customers/{customer}', [CustomerController::class, 'update']);
    });

    // Sites
    Route::get('/sites', [SiteController::class, 'index']);
    Route::get('/sites/{site}', [SiteController::class, 'show']);
    Route::post('/sites', [SiteController::class, 'store']);
    Route::put('/sites/{site}', [SiteController::class, 'update']);
    Route::get('/sites/{site}/history', [SiteController::class, 'history']);
    Route::get('/sites/{site}/comparison', [SiteController::class, 'comparison']);

    // Inspectors (admin-only writes)
    Route::get('/inspectors', [InspectorController::class, 'index']);
    Route::middleware('admin')->group(function () {
        Route::post('/inspectors', [InspectorController::class, 'store']);
        Route::put('/inspectors/{inspector}', [InspectorController::class, 'update']);
    });

    // Findings
    Route::post('/findings', [FindingController::class, 'store']);
    Route::put('/findings/{finding}', [FindingController::class, 'update']);

    // Evidence & signatures (multipart uploads)
    Route::post('/evidence', [EvidenceController::class, 'store']);
    Route::delete('/evidence/{evidence}', [EvidenceController::class, 'destroy']);
    Route::post('/signatures', [SignatureController::class, 'store']);

    // Reports & activity log
    Route::get('/reports/{inspection}', [ReportController::class, 'show']);
    Route::get('/activities', [ActivityController::class, 'index']);
});
