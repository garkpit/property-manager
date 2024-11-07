<script lang="ts">
  import PageTemplate from "$lib/components/PageTemplate.svelte";
  import { getUser, updateUser } from "$lib/services/backend.svelte";
  import { Input } from "$lib/components/ui/input";
  import { Textarea } from "$lib/components/ui/textarea";
  import { Label } from "$lib/components/ui/label";
  import { Button } from "$lib/components/ui/button";
  import { toast } from "svelte-sonner";
  import { Check } from "lucide-svelte";

  const user = $derived(getUser());

  let firstname = $state(user?.user_metadata?.firstname ?? "");
  let lastname = $state(user?.user_metadata?.lastname ?? "");
  let bio = $state(user?.user_metadata?.bio ?? "");

  $effect(() => {
    firstname = user?.user_metadata?.firstname ?? "";
    lastname = user?.user_metadata?.lastname ?? "";
    bio = user?.user_metadata?.bio ?? "";
  });

  async function handleSubmit() {
    // TODO: Implement save functionality
    console.log({ firstname, lastname, bio });
    const { error } = await updateUser({
      data: {
        firstname,
        lastname,
        bio,
      },
    });
    if (error) {
      toast.error("ERROR", {
        description: error.message,
      });
    } else {
      toast.success("SUCCESS", {
        description: "Profile updated",
      });
    }
  }
</script>

<PageTemplate>
  {#snippet TopCenter()}
    Account
  {/snippet}
  {#snippet TopRight()}
    <Button variant="ghost" size="icon" onclick={handleSubmit} class="h-9 w-9">
      <Check class="h-5 w-5" />
      <span class="sr-only">Save changes</span>
    </Button>
  {/snippet}

  {#snippet Middle()}
    <form
      class="w-full max-w-xl space-y-6"
      onsubmit={(e) => {
        e.preventDefault();
        handleSubmit();
      }}
    >
      <!-- First Name -->
      <div class="grid w-full gap-1.5">
        <Label for="firstname">First Name</Label>
        <Input
          id="firstname"
          bind:value={firstname}
          placeholder="Enter your first name"
        />
      </div>

      <!-- Last Name -->
      <div class="grid w-full gap-1.5">
        <Label for="lastname">Last Name</Label>
        <Input
          id="lastname"
          bind:value={lastname}
          placeholder="Enter your last name"
        />
      </div>

      <!-- Email (Read-only) -->
      <div class="grid w-full gap-1.5">
        <Label for="email">Email</Label>
        <Input id="email" type="email" value={user?.email ?? ""} disabled />
      </div>

      <!-- Bio -->
      <div class="grid w-full gap-1.5">
        <Label for="bio">Bio</Label>
        <Textarea
          id="bio"
          bind:value={bio}
          placeholder="Tell us about yourself"
          class="resize-y min-h-[100px]"
        />
      </div>

      <Button type="submit">Save Changes</Button>
    </form>
  {/snippet}
</PageTemplate>
