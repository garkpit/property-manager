<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";
  import type { Transaction } from "$lib/services/transactionService.svelte";
  import { getPropertyTransactions } from "$lib/services/transactionService.svelte";
  import TransactionModal from "./TransactionModal.svelte";
  import { createEventDispatcher } from "svelte";

  const dispatch = createEventDispatcher();

  let { property, showModal } = $props<{
    property: Partial<Property>;
    showModal: boolean;
  }>();

  let transactions = $state<Transaction[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);

  async function loadTransactions() {
    if (!property.id) return;

    loading = true;
    error = null;

    const { data, error: loadError } = await getPropertyTransactions(property.id);

    if (loadError) {
      error = loadError.message;
      loading = false;
      return;
    }

    transactions = data || [];
    loading = false;
  }

  $effect(() => {
    loadTransactions();
  });

  function formatCurrency(amount: number) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(amount);
  }

  function formatDate(date: string) {
    return new Date(date).toLocaleDateString();
  }
</script>

<div class="p-4">
  <h2 class="text-2xl font-semibold mb-4">Property Transactions</h2>

  {#if loading}
    <div class="text-center py-4">
      <span class="loading loading-spinner loading-md"></span>
    </div>
  {:else if error}
    <p class="text-red-500">{error}</p>
  {:else if transactions.length === 0}
    <p class="text-gray-500">No transactions found for this property.</p>
  {:else}
    <div class="overflow-x-auto">
      <table class="w-full">
        <thead>
          <tr class="border-b">
            <th class="text-left py-2">Type</th>
            <th class="text-left py-2">Start Date</th>
            <th class="text-left py-2">End Date</th>
            <th class="text-right py-2">Amount</th>
            <th class="text-right py-2">Balance</th>
            <th class="text-left py-2">Description</th>
          </tr>
        </thead>
        <tbody>
          {#each transactions as transaction}
            <tr class="border-b hover:bg-gray-50">
              <td class="py-2 capitalize">{transaction.transaction_type}</td>
              <td class="py-2">{formatDate(transaction.start_date)}</td>
              <td class="py-2">{transaction.end_date ? formatDate(transaction.end_date) : '-'}</td>
              <td class="py-2 text-right">{formatCurrency(transaction.amount)}</td>
              <td class="py-2 text-right">{formatCurrency(transaction.balance)}</td>
              <td class="py-2">{transaction.description}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}

  {#if showModal}
    <TransactionModal
      propertyId={property.id || ""}
      onClose={() => dispatch('modalClose')}
      onSave={() => {
        dispatch('modalClose');
        loadTransactions();
      }}
    />
  {/if}
</div>
