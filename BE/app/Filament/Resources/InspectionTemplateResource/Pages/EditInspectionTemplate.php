<?php

namespace App\Filament\Resources\InspectionTemplateResource\Pages;

use App\Filament\Resources\InspectionTemplateResource;
use App\Models\InspectionTemplate;
use App\Models\TemplateChecklistItem;
use App\Models\TemplateSection;
use Filament\Actions;
use Filament\Resources\Pages\Concerns\InteractsWithRecord;
use Filament\Resources\Pages\Page;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Support\Collection;

/**
 * Template Builder: the template list on the left; the selected template's
 * name, description, numbered sections and their checklist items on the
 * right. Every edit is saved immediately.
 *
 * @property InspectionTemplate $record
 */
class EditInspectionTemplate extends Page
{
    use InteractsWithRecord;

    protected static string $resource = InspectionTemplateResource::class;

    protected static string $view = 'filament.pages.template-builder';

    public string $name = '';

    public string $description = '';

    public ?int $openSection = null;

    public function mount(int|string $record): void
    {
        $this->record = $this->resolveRecord($record);
        $this->name = $this->record->name;
        $this->description = (string) $this->record->description;
    }

    public function getTitle(): string|Htmlable
    {
        return 'Inspection Templates';
    }

    public function getBreadcrumbs(): array
    {
        return [];
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('new')
                ->label('New Template')
                ->icon('heroicon-m-plus')
                ->url(InspectionTemplateResource::getUrl('create')),
        ];
    }

    /** @return Collection<int, InspectionTemplate> */
    public function getTemplates(): Collection
    {
        return InspectionTemplate::query()
            ->withCount('sections')
            ->with('sections.checklistItems')
            ->orderBy('id')
            ->get();
    }

    /** @return Collection<int, TemplateSection> */
    public function getSections(): Collection
    {
        return $this->record->sections()->with('checklistItems')->get();
    }

    public function updatedName(): void
    {
        $this->validate(['name' => ['required', 'string', 'max:255']]);
        $this->record->update(['name' => trim($this->name)]);
    }

    public function updatedDescription(): void
    {
        $this->validate(['description' => ['nullable', 'string', 'max:2000']]);
        $this->record->update(['description' => trim($this->description) ?: null]);
    }

    public function toggleSection(int $id): void
    {
        $this->openSection = $this->openSection === $id ? null : $id;
    }

    public function addSection(): void
    {
        $section = $this->record->sections()->create([
            'title' => 'New Section',
            'sort_order' => ((int) $this->record->sections()->max('sort_order')) + 1,
        ]);
        $this->openSection = $section->id;
    }

    public function renameSection(int $id, string $title): void
    {
        $title = trim($title);
        if ($title !== '') {
            $this->section($id)->update(['title' => mb_substr($title, 0, 255)]);
        }
    }

    public function moveSection(int $id, int $direction): void
    {
        $sections = $this->record->sections()->get()->values();
        $index = $sections->search(fn (TemplateSection $s) => $s->id === $id);
        $swap = $sections->get($index + $direction);
        if ($index === false || ! $swap) {
            return;
        }
        $current = $sections[$index];
        [$a, $b] = [$current->sort_order, $swap->sort_order];
        $current->update(['sort_order' => $b === $a ? $a + $direction : $b]);
        $swap->update(['sort_order' => $a]);
    }

    public function deleteSection(int $id): void
    {
        $this->section($id)->delete();
        if ($this->openSection === $id) {
            $this->openSection = null;
        }
    }

    public function addItem(int $sectionId): void
    {
        $section = $this->section($sectionId);
        $section->checklistItems()->create([
            'label' => 'New checklist item',
            'sort_order' => ((int) $section->checklistItems()->max('sort_order')) + 1,
        ]);
    }

    public function updateItem(int $id, string $field, mixed $value): void
    {
        $item = $this->item($id);
        match ($field) {
            'label' => trim((string) $value) !== '' ? $item->update(['label' => mb_substr(trim((string) $value), 0, 255)]) : null,
            'help_text' => $item->update(['help_text' => trim((string) $value) ?: null]),
            'requires_evidence' => $item->update(['requires_evidence' => (bool) $value]),
            default => null,
        };
    }

    public function deleteItem(int $id): void
    {
        $this->item($id)->delete();
    }

    public function deleteTemplate(): void
    {
        $this->record->delete();
        $this->redirect(InspectionTemplateResource::getUrl('index'));
    }

    private function section(int $id): TemplateSection
    {
        return $this->record->sections()->findOrFail($id);
    }

    private function item(int $id): TemplateChecklistItem
    {
        return TemplateChecklistItem::query()
            ->whereIn('section_id', $this->record->sections()->pluck('id'))
            ->findOrFail($id);
    }
}
