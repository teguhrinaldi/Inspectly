<?php

namespace App\Policies;

use App\Models\Inspection;
use App\Models\User;
use Illuminate\Auth\Access\Response;

/**
 * Every inspector can see every inspection (team view); only the assigned
 * inspector or an admin may change one (QC-001).
 */
class InspectionPolicy
{
    public function write(User $user, Inspection $inspection): Response
    {
        return $user->isAdmin() || $inspection->inspector_id === $user->id
            ? Response::allow()
            : Response::deny('Only the assigned inspector or an admin can change this inspection.');
    }
}
