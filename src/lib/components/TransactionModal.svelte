<script lang="ts">
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
  import type { Transaction } from "$lib/services/transactionService.svelte";
  import { upsertTransaction } from "$lib/services/transactionService.svelte";

  let { propertyId, onClose, onSave } = $props<{
    propertyId: string;
    onClose: () => void;
    onSave: () => void;
  }>();

  let open = $state(true);
  let saving = $state(false);
  let error = $state<string | null>(null);

  let transaction = $state<Partial<Transaction>>({
    propertyid: propertyId,
    type: "",
    amount: 0,
    balance: 0,
    start_date: new Date().toISOString().split('T')[0],
    end_date: null,
    description: "",
    status: "active",
  });

  async function handleSave() {
    saving = true;
    error = null;

    const { data, error: saveError } = await upsertTransaction(transaction);

    if (saveError) {
      error = saveError.message;
      saving = false;
      return;
    }

    saving = false;
    open = false;
    onSave();
  }

  $effect(() => {
    if (!open) {
      onClose();
    }
  });
</script>

<Dialog.Root bind:open>
  <Dialog.Content class="sm:max-w-[425px]">
    <Dialog.Header>
      <Dialog.Title>Add Transaction</Dialog.Title>
      <Dialog.Description>
        Add a new transaction for this property.
      </Dialog.Description>
    </Dialog.Header>

    <form 
      on:submit={(e) => {
        e.preventDefault();
        handleSave();
      }} 
      class="grid gap-4 py-4"
    >
      <div class="grid gap-2">
        <Label for="type">Type</Label>
        <select
          id="type"
          class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm transition-colors"
          bind:value={transaction.type}
          required
        >
          <option value="">Select type...</option>
          <option value="sale">Sale</option>
          <option value="purchase">Purchase</option>
          <option value="rental">Rental</option>
          <option value="expense">Expense</option>
          <option value="income">Income</option>
        </select>
      </div>

      <div class="grid gap-2">
        <Label for="amount">Amount</Label>
        <Input
          id="amount"
          type="number"
          step="0.01"
          bind:value={transaction.amount}
          required
        />
      </div>

      <div class="grid gap-2">
        <Label for="balance">Balance</Label>
        <Input
          id="balance"
          type="number"
          step="0.01"
          bind:value={transaction.balance}
          required
        />
      </div>

      <div class="grid gap-2">
        <Label for="start_date">Start Date</Label>
        <Input
          id="start_date"
          type="date"
          bind:value={transaction.start_date}
          required
        />
      </div>

      <div class="grid gap-2">
        <Label for="end_date">End Date</Label>
        <Input
          id="end_date"
          type="date"
          bind:value={transaction.end_date}
        />
      </div>

      <div class="grid gap-2">
        <Label for="description">Description</Label>
        <Input
          id="description"
          bind:value={transaction.description}
          placeholder="Enter transaction details..."
        />
      </div>

      {#if error}
        <p class="text-sm text-red-500">{error}</p>
      {/if}

      <Dialog.Footer>
        <Button type="button" variant="outline" onclick={() => (open = false)}>
          Cancel
        </Button>
        <Button type="submit" disabled={saving}>
          {#if saving}
            <span class="loading loading-spinner loading-xs mr-2"></span>
          {/if}
          Save
        </Button>
      </Dialog.Footer>
    </form>
  </Dialog.Content>
</Dialog.Root>
