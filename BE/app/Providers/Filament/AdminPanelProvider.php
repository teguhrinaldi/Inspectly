<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\View\PanelsRenderHook;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->brandName('Inspectly')
            ->brandLogo(fn () => view('filament.partials.brand'))
            ->brandLogoHeight('2.2rem')
            ->font('Inter')
            ->sidebarWidth('16.5rem')
            ->darkMode(false)
            // Matches the Flutter app's palette (app/lib/app/theme/app_colors.dart).
            ->colors([
                'primary' => Color::hex('#1677FF'),
                'danger' => Color::hex('#E02D2D'),
                'warning' => Color::hex('#F07A12'),
                'success' => Color::hex('#16A34A'),
                'gray' => Color::Slate,
            ])
            ->renderHook(PanelsRenderHook::HEAD_END, fn () => view('filament.partials.theme'))
            ->renderHook(PanelsRenderHook::USER_MENU_BEFORE, fn () => view('filament.partials.user-name'))
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->pages([
                \App\Filament\Pages\Dashboard::class,
                \App\Filament\Pages\Reports::class,
                \App\Filament\Pages\Settings::class,
            ])
            ->widgets([])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
