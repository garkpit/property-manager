<script lang="ts">
  import type { Property } from "$lib/services/propertyService.svelte";
  import type { Transaction } from "$lib/services/transactionService.svelte";
  import { getPropertyTransactions } from "$lib/services/transactionService.svelte";
  import TransactionModal from "./TransactionModal.svelte";
  import { createEventDispatcher } from "svelte";
  import { fade } from "svelte/transition";

  const dispatch = createEventDispatcher();

  let { property, showModal } = $props<{
    property: Partial<Property>;
    showModal: boolean;
  }>();

  let transactions = $state<Transaction[]>([]);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let selectedTransaction = $state<Transaction | null>(null);

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
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount);
  }

  function formatDate(date: string | null) {
    if (!date) return "";
    return new Date(date).toLocaleDateString();
  }
</script>

<div class="w-full p-4 md:p-6 lg:p-8 space-y-8" transition:fade>
  {#if loading}
    <div class="flex items-center justify-center h-32">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
    </div>
  {:else if error}
    <div class="bg-red-50 text-red-500 p-4 rounded-lg">{error}</div>
  {:else}
    <div class="bg-white rounded-xl shadow-sm p-6">
      <div class="overflow-x-auto -mx-6">
        <div class="inline-block min-w-full align-middle">
          <div class="overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
              <thead>
                <tr class="border-b">
                  <th class="text-left p-4 font-semibold text-gray-900">Type</th>
                  <th class="text-left p-4 font-semibold text-gray-900">Start Date</th>
                  <th class="text-left p-4 font-semibold text-gray-900 hidden md:table-cell">End Date</th>
                  <th class="text-right p-4 font-semibold text-gray-900 hidden md:table-cell">Amount</th>
                  <th class="text-right p-4 font-semibold text-gray-900 hidden md:table-cell">Balance</th>
                  <th class="text-left p-4 font-semibold text-gray-900">Status</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                {#if transactions.length === 0}
                  <tr>
                    <td colspan="6" class="text-center p-8 text-gray-500">
                      No transactions found for this property.
                    </td>
                  </tr>
                {:else}
                  {#each transactions as transaction}
                    {#if transaction.description}
                      <tr class="border-b bg-gray-50 cursor-pointer" on:click={() => selectedTransaction = transaction}>
                        <td colspan="6" class="p-4 text-sm text-gray-600">
                          {transaction.description}
                        </td>
                      </tr>
                    {/if}
                    <tr class="border-b hover:bg-gray-50 cursor-pointer" on:click={() => selectedTransaction = transaction}>
                      <td class="p-4 capitalize whitespace-nowrap">{transaction.type}</td>
                      <td class="p-4 whitespace-nowrap">{formatDate(transaction.start_date)}</td>
                      <td class="p-4 whitespace-nowrap hidden md:table-cell">
                        {transaction.end_date ? formatDate(transaction.end_date) : "-"}
                      </td>
                      <td class="p-4 text-right whitespace-nowrap hidden md:table-cell">
                        {formatCurrency(transaction.amount)}
                      </td>
                      <td class="p-4 text-right whitespace-nowrap hidden md:table-cell">
                        {formatCurrency(transaction.balance)}
                      </td>
                      <td class="p-4 whitespace-nowrap">
                        <span class={`px-2 py-1 rounded-full text-xs font-medium
                          ${
                            transaction.status === "active"
                              ? "bg-green-100 text-green-800"
                              : transaction.status === "pending"
                              ? "bg-yellow-100 text-yellow-800"
                              : transaction.status === "completed"
                              ? "bg-blue-100 text-blue-800"
                              : "bg-gray-100 text-gray-800"
                          }`}>
                          {transaction.status}
                        </span>
                      </td>
                    </tr>
                  {/each}
                {/if}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  {/if}
</div>

{#if showModal || selectedTransaction}
  <TransactionModal
    propertyId={property.id || ""}
    existingTransaction={selectedTransaction}
    onClose={() => {
      dispatch("modalClose");
      selectedTransaction = null;
    }}
    onSave={() => {
      dispatch("modalClose");
      selectedTransaction = null;
      loadTransactions();
    }}
  />
{/if}
