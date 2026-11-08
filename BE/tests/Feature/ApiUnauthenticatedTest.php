<?php

namespace Tests\Feature;

use Tests\TestCase;

/** QC-063: an API call without a token is a 401, whatever the Accept header. */
class ApiUnauthenticatedTest extends TestCase
{
    public function test_missing_token_is_401_even_without_json_accept_header(): void
    {
        $this->get('/api/me')->assertUnauthorized();
    }
}
