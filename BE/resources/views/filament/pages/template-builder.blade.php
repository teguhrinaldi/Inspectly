<x-filament-panels::page class="insp-template-builder">
    <div class="insp-split">
        <aside class="insp-card insp-template-list">
            <ul>
                @foreach ($this->getTemplates() as $template)
                    @php
                        $items = $template->sections->sum(fn ($s) => $s->checklistItems->count());
                        $active = $template->is($this->record);
                    @endphp
                    <li>
                        <a href="{{ \App\Filament\Resources\InspectionTemplateResource::getUrl('edit', ['record' => $template]) }}"
                           @class(['insp-template-row', 'is-active' => $active])>
                            <span class="insp-template-icon">
                                <x-filament::icon icon="heroicon-o-document-text" class="h-5 w-5" />
                            </span>
                            <span class="insp-template-text">
                                <span class="insp-template-name">{{ $template->name }}</span>
                                <span class="insp-template-meta">{{ $items }} {{ \Illuminate\Support\Str::plural('item', $items) }} · {{ $template->sections_count }} {{ \Illuminate\Support\Str::plural('section', $template->sections_count) }}</span>
                            </span>
                        </a>
                    </li>
                @endforeach
            </ul>
        </aside>

        <section class="insp-card insp-editor">
            <div class="insp-editor-head">
                <h2 class="insp-editor-title">Edit Template</h2>
                <button type="button" class="insp-icon-btn is-danger" title="Delete template" wire:click="deleteTemplate" wire:confirm="Delete this template?"><x-filament::icon icon="heroicon-o-trash" class="h-4 w-4" /></button>
            </div>

            <label class="insp-input">
                <span class="sr-only">Template name</span>
                <input type="text" wire:model.blur="name" aria-label="Template name">
            </label>
            @error('name') <p class="insp-error">{{ $message }}</p> @enderror

            <label class="insp-input insp-textarea">
                <span class="insp-input-label">Description</span>
                <textarea rows="2" wire:model.blur="description" aria-label="Description"></textarea>
            </label>

            <h3 class="insp-editor-sub">Sections</h3>
            <ol class="insp-sections">
                @foreach ($this->getSections() as $index => $section)
                    <li wire:key="section-{{ $section->id }}" @class(['insp-section', 'is-open' => $openSection === $section->id])>
                        <button type="button" class="insp-section-row" wire:click="toggleSection({{ $section->id }})"
                                aria-expanded="{{ $openSection === $section->id ? 'true' : 'false' }}">
                            <span class="insp-section-no">{{ $index + 1 }}</span>
                            <span class="insp-section-text">
                                <span class="insp-section-title">{{ $section->title }}</span>
                                <span class="insp-section-meta">{{ $section->checklistItems->count() }} {{ \Illuminate\Support\Str::plural('item', $section->checklistItems->count()) }}</span>
                            </span>
                            <x-filament::icon icon="heroicon-m-chevron-right" class="h-4 w-4 insp-chevron" />
                        </button>

                        @if ($openSection === $section->id)
                            <div class="insp-section-body">
                                <div class="insp-section-tools">
                                    <input type="text" value="{{ $section->title }}" aria-label="Section title"
                                           wire:change="renameSection({{ $section->id }}, $event.target.value)">
                                    <button type="button" title="Move up" wire:click="moveSection({{ $section->id }}, -1)"><x-filament::icon icon="heroicon-m-arrow-up" class="h-4 w-4" /></button>
                                    <button type="button" title="Move down" wire:click="moveSection({{ $section->id }}, 1)"><x-filament::icon icon="heroicon-m-arrow-down" class="h-4 w-4" /></button>
                                    <button type="button" title="Delete section" class="is-danger" wire:click="deleteSection({{ $section->id }})" wire:confirm="Delete this section and its checklist items?"><x-filament::icon icon="heroicon-m-trash" class="h-4 w-4" /></button>
                                </div>
                                @foreach ($section->checklistItems as $item)
                                    <div class="insp-item" wire:key="item-{{ $item->id }}">
                                        <input type="text" value="{{ $item->label }}" aria-label="Checklist item"
                                               wire:change="updateItem({{ $item->id }}, 'label', $event.target.value)">
                                        <input type="text" value="{{ $item->help_text }}" placeholder="Question shown to the inspector" aria-label="Question"
                                               wire:change="updateItem({{ $item->id }}, 'help_text', $event.target.value)">
                                        <label class="insp-check">
                                            <input type="checkbox" @checked($item->requires_evidence)
                                                   wire:change="updateItem({{ $item->id }}, 'requires_evidence', $event.target.checked)">
                                            Photo required
                                        </label>
                                        <button type="button" title="Delete item" class="is-danger" wire:click="deleteItem({{ $item->id }})"><x-filament::icon icon="heroicon-m-x-mark" class="h-4 w-4" /></button>
                                    </div>
                                @endforeach
                                <button type="button" class="insp-link" wire:click="addItem({{ $section->id }})">+ Add checklist item</button>
                            </div>
                        @endif
                    </li>
                @endforeach
            </ol>

            <button type="button" class="insp-primary-btn" wire:click="addSection">
                <x-filament::icon icon="heroicon-m-plus" class="h-5 w-5" /> Add Section
            </button>
        </section>
    </div>
</x-filament-panels::page>
