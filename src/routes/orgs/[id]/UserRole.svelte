<script lang="ts">
  import * as Select from "$lib/components/ui/select/index.js";

  const roles = [
    { value: "Owner", label: "Owner" },
    { value: "Manager", label: "Manager" },
    { value: "Member", label: "Member" },
    { value: "Read Only", label: "Read Only" },
  ];

  const { user, classes } = $props<{
    user: any;
    classes?: string;
  }>();
  let value = $state(user.user_role);

  const triggerContent = $derived(
    roles.find((f) => f.value === value)?.label ?? "Select role",
  );

  // Update when the role changes
  $effect(() => {
    if (value !== user.user_role) {
      user.new_user_role = value;
      console.log("user.user_role", user.user_role);
      console.log("user.new_user_role", user.new_user_role);
    } else {
      user.new_user_role = user.user_role;
    }
  });
</script>

<Select.Root type="single" name="user_role" bind:value>
  <Select.Trigger class="w-[180px] {classes}">
    {triggerContent}
  </Select.Trigger>
  <Select.Content>
    <Select.Group>
      <Select.GroupHeading>Role</Select.GroupHeading>
      {#each roles as role}
        <Select.Item value={role.value} label={role.label}
          >{role.label}</Select.Item
        >
      {/each}
    </Select.Group>
  </Select.Content>
</Select.Root>
