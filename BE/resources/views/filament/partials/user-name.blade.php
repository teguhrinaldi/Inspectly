<span class="insp-user-name">
    <b>{{ auth()->user()?->name }}</b>
    <small>{{ auth()->user()?->isAdmin() ? 'Administrator' : ucfirst((string) auth()->user()?->role) }}</small>
</span>
