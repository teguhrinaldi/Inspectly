<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
    :root {
        --insp-primary: #1677FF;
        --insp-navy: #16244A;
        --insp-sidebar: #0E1A33;
        --insp-bg: #F5F7FB;
        --insp-border: #E5EAF2;
        --insp-muted: #5E6E8E;
        --insp-faint: #97A3BA;
    }
    body.fi-body { font-family: Inter, ui-sans-serif, system-ui, sans-serif; background: var(--insp-bg); color: var(--insp-navy); }
    .fi-main { background: var(--insp-bg); }

    /* Sidebar */
    .fi-sidebar { background: var(--insp-sidebar) !important; border-right: 0 !important; }
    .fi-sidebar-header { background: var(--insp-sidebar) !important; box-shadow: none !important; border: 0 !important; }
    .fi-sidebar-nav { padding-top: .5rem; }
    .fi-sidebar-item-button { border-radius: 10px !important; padding-top: .7rem !important; padding-bottom: .7rem !important; }
    .fi-sidebar-item-label, .fi-sidebar-item-icon { color: #C4CCE0 !important; }
    .fi-sidebar-item-button:hover { background: rgba(255,255,255,.06) !important; }
    .fi-sidebar-item.fi-active .fi-sidebar-item-button { background: var(--insp-primary) !important; }
    .fi-sidebar-item.fi-active .fi-sidebar-item-label, .fi-sidebar-item.fi-active .fi-sidebar-item-icon { color: #fff !important; }
    .fi-sidebar .fi-icon-btn { color: #C4CCE0 !important; }
    .insp-brand { display: inline-flex; align-items: center; gap: .6rem; color: #fff; }
    .insp-brand svg { color: #3B8BFF; }
    .insp-brand-name { font-weight: 700; font-size: 1.35rem; letter-spacing: -.02em; }
    .fi-topbar nav { background: var(--insp-bg) !important; box-shadow: none !important; }
    .fi-topbar .insp-brand { color: var(--insp-navy); }

    /* Shared cards / chips */
    .insp-card { background: #fff; border: 1px solid var(--insp-border); border-radius: 16px; padding: 1.1rem 1.2rem; box-shadow: 0 4px 14px rgba(27,58,107,.04); }
    .insp-card-title { display: flex; align-items: center; gap: .5rem; font-weight: 600; font-size: .98rem; color: var(--insp-navy); margin-bottom: .75rem; }
    .insp-chip { display: inline-block; padding: .25rem .7rem; border-radius: 999px; font-size: .78rem; font-weight: 600; white-space: nowrap; }
    .tone-blue { background: #EAF2FF; color: #1677FF; }
    .tone-orange { background: #FFF1E3; color: #F07A12; }
    .tone-green { background: #E7F7EE; color: #16A34A; }
    .tone-red { background: #FDEBEB; color: #E02D2D; }
    .tone-coral { background: #FDECE6; color: #E4572E; }
    .tone-amber { background: #FFF7E0; color: #E5A000; }
    .tone-slate { background: #EEF2F7; color: #64748B; }
    .insp-empty { color: var(--insp-muted); font-size: .9rem; }
    .insp-chevron { color: var(--insp-faint); }

    /* Dashboard */
    .insp-dashboard .fi-header { display: none; }
    .insp-greeting { display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; }
    .insp-greeting h1 { font-size: 1.6rem; font-weight: 700; letter-spacing: -.02em; }
    .insp-greeting p { color: var(--insp-muted); margin-top: .2rem; }
    .insp-date { display: flex; align-items: center; gap: .4rem; color: var(--insp-muted); font-size: .88rem; padding-top: .5rem; }
    .insp-stats { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 1rem; }
    .insp-stat { display: flex; gap: .9rem; align-items: flex-start; }
    .insp-stat-icon { width: 46px; height: 46px; border-radius: 12px; display: grid; place-items: center; flex: none; }
    .insp-stat-label { color: var(--insp-muted); font-size: .86rem; }
    .insp-stat-value { font-size: 1.7rem; font-weight: 700; line-height: 1.2; }
    .insp-trend { display: flex; align-items: center; gap: .25rem; font-size: .8rem; font-weight: 600; margin-top: .2rem; }
    .insp-trend span { color: var(--insp-faint); font-weight: 500; }
    .insp-trend.is-up { color: #16A34A; }
    .insp-trend.is-down { color: #E02D2D; }
    .insp-trend.is-flat { color: var(--insp-faint); font-weight: 500; }
    .insp-grid { display: grid; grid-template-columns: 1.15fr 1fr; gap: 1rem; }
    .insp-col { display: flex; flex-direction: column; gap: 1rem; }
    .insp-row { display: flex; align-items: center; gap: .9rem; padding: .8rem 0; border-top: 1px solid var(--insp-border); }
    .insp-row:first-of-type { border-top: 0; }
    .insp-thumb { width: 44px; height: 44px; border-radius: 12px; object-fit: cover; flex: none; }
    .insp-thumb-icon { background: #EAF2FF; color: #1677FF; display: grid; place-items: center; }
    .insp-row-text { display: flex; flex-direction: column; flex: 1; min-width: 0; }
    .insp-row-title { font-weight: 600; font-size: .92rem; color: var(--insp-navy); }
    .insp-row-sub { color: var(--insp-muted); font-size: .82rem; }
    .insp-risk-body { display: flex; align-items: center; gap: 1.5rem; }
    .insp-donut { position: relative; width: 180px; flex: none; }
    .insp-donut .fi-wi-chart > section, .insp-donut .fi-section { border: 0 !important; box-shadow: none !important; background: transparent !important; }
    .insp-donut .fi-section-content { padding: 0 !important; }
    .insp-donut-value { position: absolute; inset: 0; display: grid; place-items: center; font-size: 1.6rem; font-weight: 700; pointer-events: none; }
    .insp-legend { flex: 1; display: flex; flex-direction: column; gap: .65rem; }
    .insp-legend li { display: flex; align-items: center; gap: .6rem; font-size: .9rem; color: var(--insp-muted); padding: .45rem .7rem; border: 1px solid var(--insp-border); border-radius: 10px; }
    .insp-legend b { margin-left: auto; color: var(--insp-navy); }
    .insp-legend .dot { width: 12px; height: 12px; border-radius: 999px; }
    .insp-legend .dot.tone-green { background: #0E9F6E; } .insp-legend .dot.tone-orange { background: #F07A12; } .insp-legend .dot.tone-red { background: #E02D2D; }
    .insp-foot { color: var(--insp-faint); font-size: .76rem; margin-top: .7rem; }
    .insp-finding { display: flex; align-items: center; gap: .8rem; padding: .65rem .7rem; border: 1px solid var(--insp-border); border-radius: 12px; margin-top: .5rem; }
    .insp-finding-icon { width: 34px; height: 34px; border-radius: 999px; display: grid; place-items: center; flex: none; }
    .sev-critical { color: #E02D2D; } .sev-high { color: #F07A12; } .sev-medium { color: #E5A000; } .sev-low { color: #16A34A; }

    .insp-trend-dot { width: 18px; height: 18px; border-radius: 999px; display: inline-grid; place-items: center; }
    .insp-trend.is-up .insp-trend-dot { background: #E7F7EE; }
    .insp-trend.is-down .insp-trend-dot { background: #FDEBEB; }
    .insp-donut svg { display: block; }

    /* Template builder */
    .insp-split { display: grid; grid-template-columns: minmax(260px, 40%) 1fr; gap: 1.25rem; align-items: stretch; }
    .insp-template-list { padding: .9rem; }
    .insp-template-list ul { display: flex; flex-direction: column; gap: .6rem; }
    .insp-template-row { position: relative; display: flex; align-items: center; gap: .9rem; padding: 1rem; border: 1px solid var(--insp-border); border-radius: 14px; background: #fff; }
    .insp-template-row:hover { background: #F8FAFE; }
    .insp-template-row.is-active { background: #EFF5FF; border-color: #DCE8FB; }
    .insp-template-row.is-active::before { content: ""; position: absolute; left: -1px; top: 10px; bottom: 10px; width: 3px; border-radius: 3px; background: var(--insp-primary); }
    .insp-template-icon { width: 44px; height: 44px; border-radius: 999px; background: #EAF2FF; color: var(--insp-primary); display: grid; place-items: center; flex: none; }
    .insp-template-text { display: flex; flex-direction: column; flex: 1; min-width: 0; gap: .15rem; }
    .insp-template-name { font-weight: 600; font-size: .95rem; color: var(--insp-navy); }
    .insp-template-row.is-active .insp-template-name { color: var(--insp-primary); }
    .insp-template-meta { color: var(--insp-muted); font-size: .82rem; }
    .insp-editor { padding: 1.3rem 1.3rem 1.4rem; }
    .insp-editor-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: .9rem; }
    .insp-editor-title { font-size: 1.05rem; font-weight: 600; color: var(--insp-navy); }
    .insp-editor-sub { font-size: 1rem; font-weight: 600; color: var(--insp-navy); margin: 1.2rem 0 .7rem; }
    .insp-input { display: block; margin-bottom: .75rem; border: 1px solid var(--insp-border); border-radius: 12px; background: #fff; padding: .15rem .9rem; }
    .insp-input:focus-within { border-color: var(--insp-primary); box-shadow: 0 0 0 3px rgba(22,119,255,.12); }
    .insp-input input, .insp-input textarea { width: 100%; border: 0; outline: 0; box-shadow: none !important; padding: .7rem 0; font-size: .95rem; color: var(--insp-navy); background: transparent; resize: none; }
    .insp-textarea { padding-top: .55rem; }
    .insp-input-label { display: block; font-size: .8rem; color: var(--insp-faint); }
    .insp-textarea textarea { padding-top: .2rem; color: var(--insp-muted); }
    .insp-error { color: #E02D2D; font-size: .8rem; margin: -.4rem 0 .6rem; }
    .insp-sections { display: flex; flex-direction: column; gap: .7rem; }
    .insp-section { border: 1px solid var(--insp-border); border-radius: 14px; background: #fff; }
    .insp-section-row { width: 100%; display: flex; align-items: center; gap: 1rem; padding: .95rem 1rem; text-align: left; }
    .insp-section-no { width: 34px; height: 34px; border-radius: 999px; background: #EAF2FF; color: var(--insp-primary); font-weight: 600; display: grid; place-items: center; flex: none; }
    .insp-section-text { display: flex; flex-direction: column; flex: 1; gap: .15rem; }
    .insp-section-title { font-weight: 600; font-size: .95rem; color: var(--insp-navy); }
    .insp-section-meta { font-size: .82rem; color: var(--insp-muted); }
    .insp-section.is-open .insp-chevron { transform: rotate(90deg); }
    .insp-section-body { border-top: 1px solid var(--insp-border); padding: .8rem 1rem 1rem; display: flex; flex-direction: column; gap: .5rem; }
    .insp-section-tools, .insp-item { display: flex; align-items: center; gap: .5rem; }
    .insp-section-tools input, .insp-item input[type=text] { flex: 1; min-width: 0; border: 1px solid var(--insp-border); border-radius: 10px; padding: .5rem .7rem; font-size: .88rem; color: var(--insp-navy); }
    .insp-section-tools button, .insp-item button, .insp-icon-btn { width: 32px; height: 32px; border-radius: 9px; display: grid; place-items: center; color: var(--insp-muted); border: 1px solid var(--insp-border); background: #fff; flex: none; }
    .is-danger { color: #E02D2D !important; }
    .insp-check { display: flex; align-items: center; gap: .35rem; font-size: .8rem; color: var(--insp-muted); white-space: nowrap; }
    .insp-link { align-self: flex-start; color: var(--insp-primary); font-weight: 600; font-size: .86rem; }
    .insp-primary-btn { margin-top: 1.1rem; width: 100%; display: flex; align-items: center; justify-content: center; gap: .5rem; background: var(--insp-primary); color: #fff; font-weight: 600; border-radius: 12px; padding: .85rem 1rem; }
    .insp-primary-btn:hover { background: #0B63E5; }

    /* Filament presentation overrides */
    .fi-breadcrumbs { display: none !important; }
    .fi-header-heading { font-weight: 700 !important; letter-spacing: -.02em; color: var(--insp-navy); }
    .fi-btn { border-radius: 12px !important; font-weight: 600 !important; }
    .fi-section, .fi-ta-ctn { border-radius: 16px !important; box-shadow: 0 4px 14px rgba(27,58,107,.04) !important; --tw-ring-color: var(--insp-border) !important; }
    .fi-ta-header-cell { background: #F8FAFE !important; }
    .fi-ta-header-cell-label { color: var(--insp-muted) !important; font-weight: 600 !important; }
    .fi-input-wrp { border-radius: 12px !important; }
    .fi-badge { border-radius: 999px !important; font-weight: 600 !important; }

    /* Login: the welcome screen's photo, blue wash and card treatment */
    .fi-simple-layout { background: linear-gradient(90deg, #0E1A33 0%, #16335F 45%, rgba(22,51,95,.55) 62%, rgba(22,51,95,0) 80%), url("/demo-assets/hero_inspector.jpg") right center / auto 100% no-repeat, #0E1A33 !important; }
    .fi-simple-main-ctn { justify-content: flex-start !important; padding-left: 12vw; }
    .insp-user-name { font-weight: 600; font-size: .92rem; color: var(--insp-navy); margin-right: .6rem; }
    .fi-simple-main { border-radius: 28px !important; box-shadow: 0 24px 60px rgba(10,20,36,.35) !important; }
    .fi-simple-main .insp-brand { color: var(--insp-navy); }
    .fi-simple-main .insp-brand svg { color: var(--insp-primary); }
    .fi-simple-header-heading { font-weight: 700 !important; color: var(--insp-navy); }
    .fi-simple-main .fi-btn { min-height: 3.1rem; border-radius: 16px !important; }

    /* ---- Tablet/admin redesign (docs/design/reference_a_tablet_admin.png, reference_b_admin_inspections.png) ---- */
    .fi-main { max-width: none !important; padding-left: 1.5rem !important; padding-right: 1.5rem !important; }
    .insp-user-name { display: flex; flex-direction: column; align-items: flex-end; line-height: 1.15; margin-right: .7rem; }
    .insp-user-name b { font-weight: 600; font-size: .9rem; color: var(--insp-navy); }
    .insp-user-name small { font-size: .74rem; color: var(--insp-muted); font-weight: 500; }

    /* Topbar: global search as a wide rounded field on the left */
    .fi-topbar nav { padding-top: .9rem !important; padding-bottom: .4rem !important; }
    .fi-topbar nav > .ms-auto { flex: 1; margin-left: .5rem; }
    .fi-global-search { flex: 1; max-width: 460px; margin-right: auto; }
    .fi-global-search > div { width: 100%; }
    .fi-global-search-field .fi-input-wrp { background: #fff !important; border-radius: 12px !important; box-shadow: 0 2px 8px rgba(27,58,107,.03) !important; }
    .fi-global-search-field input { padding-top: .6rem !important; padding-bottom: .6rem !important; }

    /* KPI cards */
    .insp-stat { padding: 1.15rem 1.25rem; align-items: center; gap: 1.05rem; }
    .insp-stat-icon { width: 52px; height: 52px; border-radius: 14px; }
    .solid-blue { background: #EAF2FF; color: #1677FF; } .solid-green { background: #E7F7EE; color: #16A34A; }
    .solid-orange { background: #FFF1E3; color: #F07A12; } .solid-red { background: #FDEBEB; color: #E02D2D; }
    .insp-stat-body { min-width: 0; }
    .insp-stat-label { font-size: .86rem; font-weight: 500; }
    .insp-stat-value { font-size: 1.85rem; margin: .1rem 0 .15rem; letter-spacing: -.02em; color: var(--insp-navy); }
    .insp-trend { font-size: .78rem; gap: .2rem; flex-wrap: wrap; row-gap: 0; }
    .insp-trend span { margin-left: .35rem; }

    /* Dashboard layout */
    .insp-greeting h1 { font-size: 1.55rem; }
    .insp-period { position: relative; display: inline-flex; align-items: center; gap: .5rem; background: #fff; border: 1px solid var(--insp-border); border-radius: 12px; padding: .45rem .8rem; color: var(--insp-muted); font-size: .86rem; box-shadow: 0 2px 8px rgba(27,58,107,.03); }
    .insp-period select { border: 0; background-color: transparent; padding: 0 1.6rem 0 0; font-size: .86rem; font-weight: 600; color: var(--insp-navy); box-shadow: none !important; cursor: pointer; }
    .insp-period-range { border-left: 1px solid var(--insp-border); padding-left: .6rem; white-space: nowrap; }
    .insp-grid { grid-template-columns: minmax(0, 1.4fr) minmax(0, 1fr); gap: 1.25rem; }
    .insp-grid-even { grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); }
    .insp-card-head { display: flex; align-items: center; justify-content: space-between; gap: .75rem; margin-bottom: .6rem; }
    .insp-card-head .insp-card-title { margin-bottom: 0; }
    .insp-card-meta { color: var(--insp-muted); font-size: .8rem; }
    .insp-link-sm { color: var(--insp-primary); font-weight: 600; font-size: .84rem; }
    .insp-chart-legend { display: flex; gap: 1rem; flex-wrap: wrap; }
    .insp-chart-legend li { display: flex; align-items: center; gap: .4rem; color: var(--insp-muted); font-size: .78rem; }
    .insp-chart-legend span { width: 9px; height: 9px; border-radius: 3px; }
    .insp-line-chart { width: 100%; height: auto; display: block; margin-top: .4rem; }
    .insp-line-chart .insp-axis { font-size: 10.5px; fill: #97A3BA; font-family: Inter, sans-serif; }
    .insp-row { padding: .7rem .2rem; }
    .insp-row:hover .insp-row-title { color: var(--insp-primary); }
    .insp-row-end { display: flex; flex-direction: column; align-items: flex-end; gap: .3rem; flex: none; }
    .insp-row-date { color: var(--insp-faint); font-size: .76rem; }
    .insp-thumb { width: 48px; height: 48px; border-radius: 10px; }

    /* Inspections list: header, filters, rich table */
    .fi-header-subheading { color: var(--insp-muted) !important; font-size: .95rem !important; margin-top: .3rem !important; }
    .fi-resource-list-records-page .fi-header-heading { font-size: 1.75rem !important; }
    .fi-ta-ctn { overflow: hidden; }
    .fi-ta-filters-above-content-ctn { padding: 1rem 1.1rem !important; border-bottom: 1px solid var(--insp-border); }
    .fi-ta-filters-above-content-ctn .fi-fo-field-wrp-label { position: absolute !important; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0); }
    .fi-ta-filters-above-content-ctn .fi-ta-filters > div.flex:first-child { display: none; }
    .fi-ta-filters-above-content-ctn .fi-fo-component-ctn { gap: .75rem !important; }
    .fi-ta-filters-above-content-ctn .fi-input-wrp { background: #fff; }
    .fi-ta-filters-above-content-ctn select { font-size: .88rem; color: var(--insp-navy); }
    .fi-ta-filters-above-content-ctn .fi-input-wrp-prefix svg { color: var(--insp-muted) !important; }
    .fi-ta-header-toolbar { padding: .7rem 1.1rem !important; }
    .fi-ta-header-cell { padding-top: .85rem !important; padding-bottom: .85rem !important; }
    .fi-ta-header-cell-label { font-size: .82rem !important; color: var(--insp-navy) !important; }
    .fi-ta-row:hover { background: #F8FAFE !important; }
    .fi-ta-cell .fi-ta-text-item-label { font-size: .86rem; color: #34436A; }
    .fi-ta-header-cell { padding-left: .55rem !important; padding-right: .55rem !important; }
    .fi-ta-header-cell:first-child { padding-left: 1.1rem !important; }
    .fi-ta-cell > div > .fi-ta-text { padding-left: .55rem !important; padding-right: .55rem !important; padding-top: .75rem !important; padding-bottom: .75rem !important; }
    .fi-ta-cell .fi-ta-text-item-label { line-height: 1.35; }
    .insp-cell-site, .insp-cell-person { display: flex; align-items: center; gap: .7rem; padding: .7rem .55rem; }
    .insp-cell-site { padding-left: 1.1rem; }
    .insp-cell-site img, .insp-cell-site .insp-thumb-icon { width: 46px; height: 42px; border-radius: 10px; object-fit: cover; flex: none; }
    .insp-cell-site .insp-thumb-icon { display: grid; place-items: center; }
    .insp-cell-site > span:last-child { display: flex; flex-direction: column; min-width: 0; }
    .insp-cell-title { font-weight: 600; font-size: .86rem; color: var(--insp-navy); white-space: nowrap; }
    .insp-cell-sub { color: var(--insp-muted); font-size: .78rem; white-space: nowrap; }
    .insp-cell-person img, .insp-initials { width: 32px; height: 32px; border-radius: 999px; object-fit: cover; flex: none; }
    .insp-initials { display: grid; place-items: center; background: #EAF2FF; color: var(--insp-primary); font-size: .72rem; font-weight: 700; }
    .insp-cell-text { font-size: .86rem; color: #34436A; white-space: nowrap; }
    .fi-ta-cell .insp-chip { font-size: .76rem; padding: .28rem .75rem; margin: 0 .55rem; }
    .insp-cell-progress { display: flex; flex-direction: column; gap: .35rem; padding: .7rem .9rem .7rem .55rem; width: 128px; }
    .insp-cell-progress-count { font-size: .84rem; font-weight: 600; color: var(--insp-navy); }
    .insp-progress-row { display: flex; align-items: center; gap: .6rem; }
    .insp-bar { flex: 1; height: 6px; border-radius: 999px; background: #E9EEF6; overflow: hidden; }
    .insp-bar > span { display: block; height: 100%; border-radius: 999px; }
    .fill-blue { background: #1677FF; } .fill-green { background: #16A34A; }
    .fi-ta-actions .fi-icon-btn { color: var(--insp-muted) !important; }
    .fi-ta-actions-cell > div, .fi-ta-cell:last-child > div { padding-left: .25rem !important; padding-right: .75rem !important; }
    .fi-ta-cell:has(.insp-cell-site) .insp-cell-site { padding-left: 1rem; }

    @media (max-width: 1100px) {
        .insp-stats { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .insp-grid, .insp-grid-even, .insp-split { grid-template-columns: 1fr; }
    }
</style>
