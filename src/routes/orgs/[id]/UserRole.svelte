<script lang="ts">
  import * as Select from "$lib/components/ui/select/index.js";

  const roles = [
    { value: "Owner", label: "Owner" },
    { value: "Manager", label: "Manager" },
    { value: "Member", label: "Member" },
    { value: "Read Only", label: "Read Only" },
  ];

  const { initialValue } = $props<{
    initialValue: string;
  }>();
  let value = $state(initialValue);
  console.log("initialValue", initialValue);

  const triggerContent = $derived(
    roles.find((f) => f.value === value)?.label ?? "Select role",
  );
</script>

<Select.Root type="single" name="user_role" bind:value>
  <Select.Trigger class="w-[180px]">
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
