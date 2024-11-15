<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import * as Dialog from "$lib/components/ui/dialog";
  import { t } from "$lib/i18n";
  import { toast } from "svelte-sonner";
  import {
    acceptInvite,
    rejectInvite,
    getPendingInvites,
  } from "$lib/services/inviteService.svelte.ts";

  type Invitation = {
    id: string;
    orgs: { title: string }[];
    owner: { email: string; firstname: string; lastname: string }[];
    created_at: string;
  };
  let { open = $bindable() } = $props<{ open: boolean }>();
  let invitations = $state<Invitation[]>([]);
  let loading = $state(false);
  let error = $state<string | null>(null);

  function closeModal() {
    open = false;
  }

  async function loadInvitations() {
    console.log("loadInvitations");
    loading = true;
    try {
      console.log("calling getPendingInvites");
      const { data, error: inviteError } = await getPendingInvites();
      console.log(
        "loadInvitations data",
        JSON.stringify(data, null, 2) || data,
      );
      console.log("loadInvitations error", inviteError);
      if (inviteError) {
        error = inviteError;
        return;
      }
      invitations = data || [];
    } catch (e) {
      error = "Failed to load invitations";
    } finally {
      loading = false;
    }
  }

  async function handleAccept(invitationId: string) {
    loading = true;
    try {
      const { error } = await acceptInvite(invitationId);
      if (error) {
        throw new Error(error);
      }
      toast.success("SUCCESS", {
        description: $t("invitationsModal.acceptSuccess"),
      });
      // Remove the invitation from the list
      invitations = invitations.filter((inv) => inv.id !== invitationId);
    } catch (e) {
      toast.error("ERROR", {
        description: $t("invitationsModal.acceptError"),
      });
    } finally {
      loading = false;
    }
  }

  async function handleReject(invitationId: string) {
    loading = true;
    try {
      const { error } = await rejectInvite(invitationId);
      if (error) {
        throw new Error(error);
      }
      toast.success("SUCCESS", {
        description: $t("invitationsModal.rejectSuccess"),
      });
      // Remove the invitation from the list
      invitations = invitations.filter((inv) => inv.id !== invitationId);
    } catch (e) {
      toast.error("ERROR", {
        description: $t("invitationsModal.rejectError"),
      });
    } finally {
      loading = false;
    }
  }

  // Load invitations when the modal opens
  $effect(() => {
    if (open) {
      loadInvitations();
    }
  });
</script>

{#if open}
  <Dialog.Root {open} onOpenChange={(isOpen) => (open = isOpen)}>
    <Dialog.Content class="sm:max-w-[425px]">
      <Dialog.Header>
        <Dialog.Title>{$t("invitationsModal.title")}</Dialog.Title>
        <Dialog.Description>
          {$t("invitationsModal.description")}
        </Dialog.Description>
      </Dialog.Header>

      <div class="py-4">
        {#if invitations.length === 0}
          <p class="text-center text-muted-foreground">
            {$t("invitationsModal.noInvitations")}
          </p>
        {:else}
          {#each invitations as invitation}
            <div class="mb-4 rounded-lg border p-4">
              <h3 class="font-medium">{invitation.orgs.title}</h3>
              <p class="text-sm text-muted-foreground">
                {$t("invitationsModal.invitedBy", {
                  email: invitation.owner.email,
                })}
              </p>
              <div class="mt-3 flex gap-2">
                <Button
                  variant="default"
                  disabled={loading}
                  onclick={() => handleAccept(invitation.id)}
                >
                  {$t("invitationsModal.accept")}
                </Button>
                <Button
                  variant="destructive"
                  disabled={loading}
                  onclick={() => handleReject(invitation.id)}
                >
                  {$t("invitationsModal.reject")}
                </Button>
              </div>
            </div>
          {/each}
        {/if}
      </div>

      <Dialog.Footer>
        <!--
        <Button variant="outline" onclick={closeModal}>
          {$t("common.close")}
        </Button>
        -->
      </Dialog.Footer>
      <Dialog.Close on:click={closeModal} />
    </Dialog.Content>
  </Dialog.Root>
{/if}
