<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CustomerStoreRequest;
use App\Http\Requests\CustomerUpdateRequest;
use App\Http\Resources\CustomerResource;
use App\Models\Customer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Customer::query()->withCount('sites');

        if ($request->filled('search')) {
            $query->where('name', 'like', '%'.$request->string('search').'%');
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        $customers = $query->orderBy('name')->paginate(15)->withQueryString();

        return CustomerResource::collection($customers)->response();
    }

    public function show(Customer $customer): JsonResponse
    {
        $customer->loadCount('sites');

        return (new CustomerResource($customer))->response();
    }

    public function store(CustomerStoreRequest $request): JsonResponse
    {
        $customer = Customer::create($request->validated());

        return (new CustomerResource($customer))->response()->setStatusCode(201);
    }

    public function update(CustomerUpdateRequest $request, Customer $customer): JsonResponse
    {
        $customer->update($request->validated());

        return (new CustomerResource($customer))->response();
    }
}
